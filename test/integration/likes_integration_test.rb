# frozen_string_literal: true

require 'test_helper'

class LikesIntegrationTest < ActionDispatch::IntegrationTest
  test 'unauthorized users dont see like link in DOM' do
    post = posts(:one)

    get post_path(post)
    assert_response :success

    assert_select 'div#likes-section span', text: post.likes_count.to_s
    assert_select 'div#likes-section i.bi.bi-hand-thumbs-up', count: 1
    assert_select 'div#likes-section i.bi.bi-hand-thumbs-up-fill', count: 0

    assert_select 'a[href=?]', post_likes_path(post), count: 0
  end

  test 'authorized users see like UI elements and can interact with them' do
    post = posts(:two)
    user = users(:one)

    sign_in user

    initial_likes_count = post.likes_count

    get post_path(post)
    assert_response :success

    assert_select 'div#likes-section i.bi.bi-hand-thumbs-up', count: 1
    assert_select 'div#likes-section i.bi.bi-hand-thumbs-up-fill', count: 0
    assert_select 'a[href=?][data-turbo-method=?]', post_likes_path(post), 'post', count: 1

    # Add a like
    assert_difference 'PostLike.count', 1 do
      post post_likes_path(post)
    end

    assert_redirected_to post_path(post)
    follow_redirect!

    post.reload
    assert_equal initial_likes_count + 1, post.likes_count

    assert_select 'div#likes-section span', text: post.likes_count.to_s
    assert_select 'div#likes-section i.bi.bi-hand-thumbs-up-fill', count: 1
    assert_select 'div#likes-section i.bi.bi-hand-thumbs-up', count: 0

    user_like = post.post_likes.find_by(user: user)
    assert_select 'a[href=?][data-turbo-method=?]', post_like_path(post, user_like), 'delete', count: 1
  end

  test 'like removal updates UI correctly' do
    post = posts(:one)
    user = users(:one)

    sign_in user

    initial_likes_count = post.likes_count

    get post_path(post)
    assert_response :success

    assert_select 'div#likes-section i.bi.bi-hand-thumbs-up-fill', count: 1
    assert_select 'div#likes-section i.bi.bi-hand-thumbs-up', count: 0

    user_like = post.post_likes.find_by(user: user)
    assert_not_nil user_like
    assert_select 'a[href=?][data-turbo-method=?]', post_like_path(post, user_like), 'delete', count: 1

    assert_difference 'PostLike.count', -1 do
      delete post_like_path(post, user_like)
    end

    assert_redirected_to post_path(post)
    follow_redirect!

    post.reload
    assert_equal initial_likes_count - 1, post.likes_count

    assert_select 'div#likes-section span', text: post.likes_count.to_s
    assert_select 'div#likes-section i.bi.bi-hand-thumbs-up', count: 1
    assert_select 'div#likes-section i.bi.bi-hand-thumbs-up-fill', count: 0
    assert_select 'a[href=?][data-turbo-method=?]', post_likes_path(post), 'post', count: 1
  end
end
