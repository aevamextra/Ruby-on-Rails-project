class Admin::PermissionsController < ApplicationController
  before_action :require_login
  before_action :authorize_owner

  def index
    @permissions = Permission.all
  end

  def new
    @permission = Permission.new
  end

  def create
    @permission = Permission.new(permission_params)
    if @permission.save
      redirect_to admin_permissions_path, notice: "Permission created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @permission = Permission.find(params[:id])
  end

  def update
    @permission = Permission.find(params[:id])
    if @permission.update(permission_params)
      redirect_to admin_permissions_path, notice: "Permission updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @permission = Permission.find(params[:id])
    @permission.destroy
    redirect_to admin_permissions_path, notice: "Permission deleted."
  end

  private

  def permission_params
    params.require(:permission).permit(:name, :description, :resource, :action)
  end

  def authorize_owner
    redirect_to root_path, alert: "Not authorized." unless current_user.owner?
  end
end
