require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear # initialize deliveries
  end

  test "valid signup information with account activation" do
    # Sign up
    get signup_path
    assert_difference 'User.count', 1 do
      post signup_path, params:{user:{name:"Example User",
                                      email:"user@example.com",
                                      password:"password",
                                      password_confirmation:"password"}}
    end
    assert_equal 1, ActionMailer::Base.deliveries.size # assure one mail sent
    user = assigns(:user) # get @user in UsersController#create
    assert_not is_logged_in?

    # Log in before activation
    log_in_as(user)
    assert_not is_logged_in?

    # Access activation url with invalid token
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?

    # Access activation url with invalid mail address
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?

    # Access activation url with valid token and mail address
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end

  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post signup_path, params:{user:{name:"",
                                      email:"user@invalid",
                                      password:"foo",
                                      password_confirmation:"bar"}}
    end
    assert_template 'users/new'
    assert_select 'form[action="/signup"]'
    assert_select 'div#error_explanation' do
      assert_select 'ul li', 4
    end
    assert_select 'div.alert', "The form contains 4 errors."
  end
end
