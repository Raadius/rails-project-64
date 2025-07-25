require 'test_helper'
class PostsViewTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @post = posts(:three)
    @category = categories(:two)
  end

  test 'should render form when authenticated and create new post' do
    sign_in @user
    get new_post_url
    assert_response :success
    assert_select 'form' do
      assert_select 'input[name=?]', 'post[title]'
      assert_select 'select[name=?]', 'post[category_id]'
      assert_select 'textarea[name=?]', 'post[body]'
    end
  end

  test 'created post is shown on root path after creation' do
    sign_in @user
    test_post_attributes = @post.attributes
    test_post_attributes['category_id'] = @category.id

    post posts_url, params: { post: test_post_attributes }
    follow_redirect!

    assert_response :success
    assert_select 'a.h5', text: test_post_attributes['title']
  end

  test 'viewing created post shows full content' do
    sign_in @user

    test_post_attributes = @post.attributes
    test_post_attributes['category_id'] = @category.id

    post posts_url, params: { post: test_post_attributes }
    created_post = Post.last

    get post_url(created_post)

    assert_response :success
    assert_select 'h1', text: test_post_attributes['title']
    assert_select 'p', text: test_post_attributes['body']
  end
end
