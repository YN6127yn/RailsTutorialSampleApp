module SessionsHelper

  # Log in
  def log_in(user)
    session[:user_id] = user.id
  end

  # Make session permanent
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # Find current login user (if it exists)
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id:user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id:user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # If a user logged in, return true
  def logged_in?
    !current_user.nil?
  end

  # Discard permanent session
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Log out
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

end
