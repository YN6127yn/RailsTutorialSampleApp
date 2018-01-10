class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  private

    # Check if the user has already logged in
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

    def users_search_params
      params.require(:q).permit(:name_cont)
    end

    def microposts_search_params
      params.require(:q).permit(:content_cont)
    end
end
