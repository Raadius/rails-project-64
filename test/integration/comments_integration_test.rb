# frozen_string_literal: true

require 'test_helper'

class CommentsIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:one)
    @user_one = users(:one)
    @user_two = users(:two)
    @root_comment = post_comments(:root_comment)
    @child_comment = post_comments(:child_comment)
    @grandchild_comment = post_comments(:grandchild_comment)
  end

  test 'should display reply form with correct collapse attributes when signed in' do
    sign_in @user_one

    get post_path(@post)

    assert_response :success
    assert_select "a[data-bs-toggle='collapse']", minimum: 1
    assert_select "a[data-bs-target='#response_comment-#{@root_comment.id}']", 1
    assert_select "a[aria-controls='response_comment-#{@root_comment.id}']", 1
    assert_select ".collapse#response_comment-#{@root_comment.id}", 1
  end

  test 'should not display reply form when not signed in' do
    get post_path(@post)

    assert_response :success
    assert_select "a[data-bs-toggle='collapse']", 0
    assert_select '.collapse', 0
  end

  test 'should create reply via reply form successfully' do
    sign_in @user_two

    reply_content = 'This is a reply via the form'
    assert_difference('@post.post_comments.count', 1) do
      post post_comments_path(@post), params: {
        post_comment: {
          content: reply_content,
          parent_id: @root_comment.id
        }
      }
    end

    created_reply = @post.post_comments.last
    assert_equal reply_content, created_reply.content
    assert_equal @user_two, created_reply.user
    assert_equal @root_comment, created_reply.parent
    assert_equal "/#{@root_comment.id}/", created_reply.ancestry
    assert_redirected_to post_path(@post)
  end
end
