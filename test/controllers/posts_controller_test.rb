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

  test 'should not create post with invalid data' do
    sign_in @user

    # Test blank title
    invalid_attributes = @post.attributes
    invalid_attributes['title'] = ''
    invalid_attributes['category_id'] = @category.id

    assert_no_difference('Post.count') do
      post posts_url, params: { post: invalid_attributes }
    end
    assert_response :unprocessable_entity

    # Test missing category
    invalid_attributes['title'] = 'Valid Title'
    invalid_attributes['category_id'] = nil

    assert_no_difference('Post.count') do
      post posts_url, params: { post: invalid_attributes }
    end
    assert_response :unprocessable_entity
  end
end
