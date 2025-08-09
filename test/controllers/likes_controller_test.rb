# frozen_string_literal: true

require 'test_helper'

class LikesControllerTest < ActionDispatch::IntegrationTest
  test 'authorized users can add likes successfully' do
    post = posts(:two)
    user = users(:one)

    sign_in user

    initial_likes_count = post.post_likes.count

    assert_difference 'PostLike.count', 1 do
      post post_likes_path(post)
    end

    assert_redirected_to post_path(post)

    post.reload
    assert_equal initial_likes_count + 1, post.post_likes.count

    # Verify the like belongs to the correct user and post
    user_like = post.post_likes.find_by(user: user)
    assert_not_nil user_like
    assert_equal user, user_like.user
    assert_equal post, user_like.post
  end

  test 'authorized users can remove their likes successfully' do
    post = posts(:one)
    user = users(:one)

    sign_in user

    initial_likes_count = post.post_likes.count
    user_like = post.post_likes.find_by(user: user)
    assert_not_nil user_like

    assert_difference 'PostLike.count', -1 do
      delete post_like_path(post, user_like)
    end

    assert_redirected_to post_path(post)

    post.reload
    assert_equal initial_likes_count - 1, post.post_likes.count

    # Verify the like was actually removed
    assert_nil post.post_likes.find_by(user: user)
  end

  test 'unauthorized users cannot create likes' do
    post = posts(:one)

    assert_no_difference 'PostLike.count' do
      post post_likes_path(post)
    end

    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test 'unauthorized users cannot delete likes' do
    post = posts(:one)
    like = post_likes(:one)

    assert_no_difference 'PostLike.count' do
      delete post_like_path(post, like)
    end

    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test 'users can only delete their own likes' do
    post = posts(:one)
    user_one = users(:one)
    user_two = users(:two)

    user_one_like = post.post_likes.find_by(user: user_one)
    assert_not_nil user_one_like

    sign_in user_two

    assert_no_difference 'PostLike.count' do
      delete post_like_path(post, user_one_like)
    end

    assert PostLike.exists?(user_one_like.id)
  end
end
