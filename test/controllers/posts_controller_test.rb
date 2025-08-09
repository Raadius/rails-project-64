# frozen_string_literal: true

require 'test_helper'

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @category = categories(:one)
    @post = posts(:one)
  end

  test 'should get new when authenticated' do
    sign_in @user
    get new_post_url
    assert_response :success
  end

  test 'should redirect to login for new when not authenticated' do
    get new_post_url
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test 'should create post with authenticated user as creator' do
    sign_in @user

    test_post_attributes = @post.attributes
    test_post_attributes['category_id'] = @category.id

    assert_difference('Post.count') do
      post posts_url, params: { post: test_post_attributes }
    end

    created_post = Post.last

    assert_equal @user.id, created_post.creator_id
    assert_equal @category.id, created_post.category_id
    assert_equal @post.title, created_post.title
    assert_equal @post.body, created_post.body

    assert_redirected_to root_path
  end

  test 'should not create post when not authenticated' do
    test_post_attributes = @post.attributes
    test_post_attributes['category_id'] = @category.id

    assert_no_difference('Post.count') do
      post posts_url, params: { post: test_post_attributes }
    end
  end

  test 'should not create post with blank fields' do
    sign_in @user

    test_post_attributes = @post.attributes
    test_post_attributes['title'] = ''
    test_post_attributes['body'] = ''
    test_post_attributes['category_id'] = @category.id

    assert_no_difference('Post.count') do
      post posts_url, params: { post: test_post_attributes }
    end

    assert_response :unprocessable_entity
    assert_select '.alert.alert-danger',
                  text: I18n.t('forms.errors.generic.post')
    assert_select '.post_title .invalid-feedback',
                  text: I18n.t('activerecord.errors.models.post.attributes.title.blank')
    assert_select '.post_body .invalid-feedback',
                  text: I18n.t('activerecord.errors.models.post.attributes.body.blank')
  end

  test 'should not create post with not enough symbols' do
    sign_in @user

    test_post_attributes = @post.attributes
    test_post_attributes['title'] = 'Post'
    test_post_attributes['body'] = 'Not enough symbols'
    test_post_attributes['category_id'] = @category.id

    assert_no_difference('Post.count') do
      post posts_url, params: { post: test_post_attributes }
    end

    assert_response :unprocessable_entity
    assert_select '.alert.alert-danger', text: I18n.t('forms.errors.generic.post')
    assert_select '.post_title .invalid-feedback',
                  text: I18n.t('activerecord.errors.models.post.attributes.title.too_short')
    assert_select '.post_body .invalid-feedback',
                  text: I18n.t('activerecord.errors.models.post.attributes.body.too_short')
  end

  test 'should not create post with too many symbols' do
    sign_in @user

    test_post_attributes = @post.attributes
    test_post_attributes['title'] = 'Post' * 1000
    test_post_attributes['body'] = 'Too many symbols' * 1000
    test_post_attributes['category_id'] = @category.id

    assert_no_difference('Post.count') do
      post posts_url, params: { post: test_post_attributes }
    end

    assert_response :unprocessable_entity
    assert_select '.alert.alert-danger', text: I18n.t('forms.errors.generic.post')
    assert_select '.post_title .invalid-feedback',
                  text: I18n.t('activerecord.errors.models.post.attributes.title.too_long')
    assert_select '.post_body .invalid-feedback',
                  text: I18n.t('activerecord.errors.models.post.attributes.body.too_long')
  end

  test 'should not create post with invalid category' do
    sign_in @user
    test_post_attributes = @post.attributes
    test_post_attributes['category_id'] = nil

    assert_no_difference('Post.count') do
      post posts_url, params: { post: test_post_attributes }
    end

    assert_response :unprocessable_entity
    assert_select '.alert.alert-danger', text: I18n.t('forms.errors.generic.post')
    assert_select '.post_category .invalid-feedback',
                  text: I18n.t('activerecord.errors.models.post.attributes.category.required')
  end
end
