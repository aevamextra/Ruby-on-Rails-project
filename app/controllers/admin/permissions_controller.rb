class Admin::PermissionsController < ApplicationController
  before_action :require_login

  def index
    authorize User, :index?
    
    # Define the permissions matrix
    @permissions_matrix = [
      {
        module: "User Management",
        action: "Create, edit, or delete users",
        owner: true,
        admin: false,
        user: false
      },
      {
        module: "Workspaces / Projects",
        action: "Create new workspaces & projects",
        owner: true,
        admin: true,
        user: true
      },
      {
        module: "Workspaces / Projects",
        action: "Edit & delete ANY project",
        owner: true,
        admin: true,
        user: false,
        user_note: "Only their own"
      },
      {
        module: "Tasks",
        action: "Create new tasks & comment",
        owner: true,
        admin: true,
        user: true
      },
      {
        module: "Tasks",
        action: "Edit & delete ANY task",
        owner: true,
        admin: true,
        user: false,
        user_note: "Only their own"
      }
    ]
  end
end
