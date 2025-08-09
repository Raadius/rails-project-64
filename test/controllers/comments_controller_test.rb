# frozen_string_literal: true

require 'test_helper'

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:one)
    @user_one = users(:one)
    @user_two = users(:two)
    @root_comment = post_comments(:root_comment)
    @child_comment = post_comments(:child_comment)
    @grandchild_comment = post_comments(:grandchild_comment)
  end

  test 'should create root comment successfully when signed in' do
    sign_in @user_one

    comment_content = 'This is a new root comment'
    assert_difference('@post.post_comments.count', 1) do
      post post_comments_path(@post), params: {
        post_comment: { content: comment_content }
      }
    end

    created_comment = @post.post_comments.last
    assert_equal comment_content, created_comment.content
    assert_equal @user_one, created_comment.user
    assert_nil created_comment.parent
    assert created_comment.is_root?
    assert_redirected_to post_path(@post)
  end

  test 'should create reply comment with correct ancestry path when signed in' do
    sign_in @user_two
    parent_comment = @root_comment
    comment_content = 'This is a reply to root comment'

    assert_difference('@post.post_comments.count', 1) do
      post post_comments_path(@post), params: {
        post_comment: { content: comment_content, parent_id: parent_comment.id }
      }
    end

    created_comment = @post.post_comments.last
    assert_equal comment_content, created_comment.content
    assert_equal @user_two, created_comment.user
    assert_equal parent_comment, created_comment.parent
    assert_equal "/#{parent_comment.id}/", created_comment.ancestry
    assert created_comment.child_of?(parent_comment)
    assert_redirected_to post_path(@post)
  end

  test 'should create nested reply with correct ancestry path' do
    sign_in @user_one
    parent_comment = @child_comment
    comment_content = 'This is a nested reply'

    assert_difference('@post.post_comments.count', 1) do
      post post_comments_path(@post), params: {
        post_comment: { content: comment_content, parent_id: parent_comment.id }
      }
    end

    created_comment = @post.post_comments.last
    assert_equal comment_content, created_comment.content
    assert_equal parent_comment, created_comment.parent
    expected_ancestry = "/#{@root_comment.id}/#{@child_comment.id}/"
    assert_equal expected_ancestry, created_comment.ancestry
    assert created_comment.child_of?(parent_comment)
    assert_redirected_to post_path(@post)
  end

  test 'should not create comment when not signed in' do
    assert_no_difference('@post.post_comments.count') do
      post post_comments_path(@post), params: {
        post_comment: { content: 'This should not be created' }
      }
    end
    assert_response :redirect
  end

  test 'should not create comment with invalid content' do
    sign_in @user_one

    assert_no_difference('@post.post_comments.count') do
      post post_comments_path(@post), params: {
        post_comment: { content: '' }
      }
    end

    assert_response :unprocessable_entity
  end

  test 'show action should return correct subtree' do
    sign_in @user_one

    get post_comment_path(@post, @root_comment), headers: { "Accept": 'text/vnd.turbo-stream.html' }

    assert_response :success
    assert_not_nil assigns(:comment_subtree)

    subtree = assigns(:comment_subtree)
    assert subtree.is_a?(Hash), 'Expected subtree to be a Hash'

    assert subtree.size >= 1, 'Expected subtree to have at least one comment'

    subtree.each do |comment, children|
      assert comment.is_a?(PostComment), 'Expected comment to be a PostComment instance'
      assert children.is_a?(Hash), 'Expected children to be a Hash'
    end

    all_comments_in_subtree = extract_all_comments_from_subtree(subtree)
    assert all_comments_in_subtree.length >= 1, 'Expected at least one comment in subtree'
  end

  test 'show action should redirect to post for HTML format' do
    sign_in @user_one

    get post_comment_path(@post, @root_comment)

    assert_redirected_to @post
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

  test 'reply form should have correct parent_id hidden field' do
    sign_in @user_one

    get post_path(@post)

    assert_response :success
    assert_select 'form.reply-form' do
      assert_select "input[name='post_comment[parent_id]'][value='#{@root_comment.id}'][type='hidden']", 1
    end
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

  private

  def extract_all_comments_from_subtree(subtree)
    comments = []
    subtree.each do |comment, children|
      comments << comment
      comments.concat(extract_all_comments_from_subtree(children)) if children.is_a?(Hash)
    end
    comments
  end
end
