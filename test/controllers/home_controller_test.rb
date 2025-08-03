require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:two)
  end

  test 'should get index' do
    get root_url
    assert_response :found
    assert_redirected_to new_user_session_url
  end

  test 'should show empty page if authenticated with no posts' do
    # Clear dependent records first to avoid foreign key constraint issues
    PostComment.destroy_all
    Post.destroy_all

    sign_in @user
    get root_url
    assert_response :success

    assert_select 'h1', text: I18n.t('common_text.main_page_title')
    assert_select '#posts span', text: I18n.t('post.empty')
    assert_select '#posts a', text: I18n.t('post.create_new_post')
  end
end
