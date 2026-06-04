class TaskPolicy < ApplicationPolicy
  def index?
    user.has_permission?('Tasks', 'read')
  end

  def show?
    user.has_permission?('Tasks', 'read')
  end

  def create?
    user.has_permission?('Tasks', 'create')
  end

  def new?
    create?
  end

  def update?
    user.has_permission?('Tasks', 'update')
  end

  def edit?
    update?
  end

  def destroy?
    user.has_permission?('Tasks', 'delete')
  end
end