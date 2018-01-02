module SessionsHelper

  # Log in
  def log_in(user)
    session[:user_id] = user.id
  end

  # Find current login user (if it exists)
  def current_user
    @current_user ||= User.find_by(id:session[:user_id])
  end

  # If a user logged in, return true
  def logged_in?
    !current_user.nil?
  end

  # Log out
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end

end
