class Admin::UsersController < ApplicationController
  before_action :require_login
  before_action :set_user, only: %i[show edit update destroy]

  def index
    authorize User
    @users = User.all
  end

  def show
    authorize @user
  end

  def new
    authorize User
    @user = User.new
  end

  def edit
    authorize @user
  end

  def create
    authorize User
    @user = User.new(user_params)

    if @user.save
      redirect_to admin_users_path, notice: "User was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @user
    
    # We update without password if it's blank
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if @user.update(user_params)
      redirect_to admin_users_path, notice: "User was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user
    if @user == current_user
      redirect_to admin_users_path, alert: "You cannot delete yourself."
    else
      @user.destroy
      redirect_to admin_users_path, notice: "User was successfully deleted."
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role)
  end
end
