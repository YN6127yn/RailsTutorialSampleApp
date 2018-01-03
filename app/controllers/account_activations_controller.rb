class AccountActivationsController < ApplicationController

  def edit
    user = User.find_by(email: params[:email])
    # prarams[:id] is not user id but activation_token this time.(acc_act/token(id)/edit?email=...)
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
