require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
Minitest::Reporters.use!

class ActiveSupport::TestCase
  fixtures :all
  include ApplicationHelper

  # If test user is logged in, return true
  def is_logged_in?
    !session[:user_id].nil?
  end

  # Log in as test user
  def log_in_as(user)
    session[:user_id] = user.id
  end
end

class ActionDispatch::IntegrationTest

  # Log in as test user
  def log_in_as(user, password:'password', remember_me:'1')
    post login_path, params:{session:{email:user.email,
                                      password:password,
                                      remember_me:remember_me}}
  end
end
