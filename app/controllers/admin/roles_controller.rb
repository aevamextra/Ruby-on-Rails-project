class Admin::RolesController < ApplicationController
  before_action :require_login
  before_action :authorize_owner

  def index
    @roles = Role.all
  end

  def new
    @role = Role.new
  end

  def create
    @role = Role.new(role_params)
    if @role.save
      redirect_to admin_roles_path, notice: "Role created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @role = Role.find(params[:id])
  end

  def update
    @role = Role.find(params[:id])
    if @role.update(role_params)
      redirect_to admin_roles_path, notice: "Role updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @role = Role.find(params[:id])
    @role.destroy
    redirect_to admin_roles_path, notice: "Role deleted."
  end

  private

  def role_params
    params.require(:role).permit(:name, :description, permission_ids: [])
  end

  def authorize_owner
    redirect_to root_path, alert: "Not authorized." unless current_user.owner?
  end
end
