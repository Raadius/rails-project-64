# frozen_string_literal: true

require 'test_helper'
class DeviseViewTest < ActionDispatch::IntegrationTest
  test 'registration page renders correct view' do
    get new_user_registration_path

    assert_response :success
    assert_select 'h2', text: I18n.t('forms.titles.sign_up')
    assert_select 'form[action=?]', user_registration_path do
      assert_select 'input[name=?]', 'user[email]'
      assert_select 'input[name=?]', 'user[password]'
      assert_select 'input[name=?]', 'user[password_confirmation]'
      assert_select 'input[type=submit].btn.btn-primary'
    end
  end

  test 'login page renders correct view' do
    get new_user_session_path

    assert_response :success
    assert_select 'h2', text: I18n.t('forms.titles.sign_in')
    assert_select 'form[action=?]', user_session_path do
      assert_select 'input[name=?]', 'user[email]'
      assert_select 'input[name=?]', 'user[password]'
      assert_select 'input[name=?][type=checkbox]', 'user[remember_me]'
      assert_select 'input[type=submit].btn.btn-primary'
    end
  end
end
