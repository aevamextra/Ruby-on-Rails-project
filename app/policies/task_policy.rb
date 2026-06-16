class TaskPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    owns_record? || user.has_permission?('Tasks', 'read')
  end

  def create?
    user.present?
  end

  def new?
    create?
  end

  def update?
    owns_record? || user.has_permission?('Tasks', 'update')
  end

  def edit?
    update?
  end

  def destroy?
    owns_record? || user.has_permission?('Tasks', 'delete')
  end

  private

  def owns_record?
    record.respond_to?(:user_id) && record.user_id == user.id
  end
end
