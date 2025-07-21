require 'test_helper'

# TODO[ALX]: Здесь тест должен получить index со списком постов. При попытке на этой странице
# TODO[ALX]: куда-то тыкнуть, должен перенаправить на страницу входа. Пока тут тест на редирект при открытии рутовой страницы
class HomeControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get root_url
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
end
