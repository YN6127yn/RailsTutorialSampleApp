class UsersController < ApplicationController

  before_action :logged_in_user, only:[:index, :edit, :update, :destroy,
                                      :following, :followers]
  before_action :get_user, only:[:show, :destroy, :following, :followers]
  before_action :correct_user, only:[:edit, :update]
  before_action :admin_user, only: :destroy

  def index
    if params[:q] && params[:q].reject { |key, value| value.blank? }.present?
      @q = User.ransack(search_params, activated_true: true)
      @title = "Search Result"
    else
      @q = User.ransack(activated_true: true)
      @title = "All users"
    end
    @users = @q.result.paginate(page: params[:page])
  end

  def show
    redirect_to root_url and return unless @user.activated?
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  def following
    @title = "following"
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "followers"
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private

    # Strong parameter
    def user_params
      params.require(:user).permit(:name, :email,
                                   :password, :password_confirmation)
    end

    def search_params
      params.require(:q).permit(:name_cont)
    end

    # before_action

    # Search user from database by user id
    def get_user
      @user = User.find(params[:id])
    end

    # Check if the user is authorized to do the action
    def correct_user
      @user ||= get_user
      redirect_to root_url unless current_user?(@user)
    end

    #  Check if the user is administrator
    def admin_user
      redirect_to root_url unless current_user.admin?
    end
end
