class UserPolicy < ApplicationPolicy
  def index?
    user.owner?
  end

  def show?
    user.owner?
  end

  def create?
    user.owner?
  end

  def new?
    create?
  end

  def update?
    user.owner?
  end

  def edit?
    update?
  end

  def destroy?
    user.owner?
  end
end
