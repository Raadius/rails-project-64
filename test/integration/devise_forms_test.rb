require 'test_helper'

class DeviseFormsTest < ActionDispatch::IntegrationTest
  setup do
    # Clear dependent records first to avoid foreign key constraint issues
    PostComment.destroy_all
    Post.destroy_all
    User.destroy_all
  end

  test 'registration form shows validation errors for blank fields' do
    post user_registration_path, params: { user: { email: '', password: '', password_confirmation: '' } }

    assert_response :unprocessable_entity
    assert_select '.alert.alert-danger', text: I18n.t('forms.errors.review_problems_below')
  end

  test 'registration form shows error for invalid email format' do
    post user_registration_path, params: {
      user: {
        email: 'invalid_email',
        password: 'password123',
        password_confirmation: 'password123'
      }
    }

    assert_response :unprocessable_entity
    assert_select '.invalid-feedback', text: I18n.t('activerecord.errors.models.user.attributes.email.invalid')
  end

  test 'registration form shows error for password too short' do
    post user_registration_path, params: {
      user: {
        email: 'test@example.com',
        password: '12345',
        password_confirmation: '12345'
      }
    }

    assert_response :unprocessable_entity
    assert_select '.invalid-feedback',
                  text: I18n.t('activerecord.errors.models.user.attributes.password.too_short', count: 6)
  end

  test 'registration form shows error for password confirmation mismatch' do
    post user_registration_path, params: {
      user: {
        email: 'test@example.com',
        password: 'password123',
        password_confirmation: 'different123'
      }
    }

    assert_response :unprocessable_entity
    assert_select '.invalid-feedback',
                  text: I18n.t('activerecord.errors.models.user.attributes.password_confirmation.confirmation')
  end

  test 'successful registration redirects to root path' do
    post user_registration_path, params: {
      user: {
        email: 'newuser@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      }
    }

    assert_redirected_to root_path
    follow_redirect!
  end

  test 'login form shows flash error for invalid credentials' do
    User.create!(email: 'existing@example.com', password: 'password123')

    post user_session_path, params: {
      user: {
        email: 'existing@example.com',
        password: 'wrongpassword'
      }
    }

    assert_response :unprocessable_entity
    assert_select '.alert.alert-info', text: I18n.t('devise.failure.user.invalid', authentication_keys: 'Email')
  end

  test 'login form shows flash error for non-existent user' do
    post user_session_path, params: {
      user: {
        email: 'nonexistent@example.com',
        password: 'password123'
      }
    }

    assert_response :unprocessable_entity
    assert_select '.alert.alert-info', text: I18n.t('devise.failure.user.not_found_in_database', authentication_keys: 'Email')
  end

  test 'successful login redirects to root path' do
    User.create!(email: 'testuser@example.com', password: 'password123')

    post user_session_path, params: {
      user: {
        email: 'testuser@example.com',
        password: 'password123'
      }
    }

    assert_redirected_to root_path
    follow_redirect!
  end
end
