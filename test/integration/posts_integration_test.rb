# frozen_string_literal: true

require 'test_helper'

class PostsIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @category = categories(:one)
    @post = posts(:one)
  end

  test 'should display validation errors for blank fields' do
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

  test 'should display validation errors for insufficient content length' do
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

  test 'should display validation errors for excessive content length' do
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

  test 'should display validation error for missing category' do
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
