class User < ApplicationRecord
  has_secure_password
  validates :email, presence: true, uniqueness: true

  belongs_to :role, optional: true

  has_many :projects, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :comments, dependent: :destroy

  def owner?
    role&.name == 'owner' || role&.name == 'system_admin'
  end

  def admin?
    role&.name == 'admin'
  end

  def user?
    role&.name == 'user'
  end

  def has_permission?(resource, action)
    return true if owner? # System admin/owner bypasses all checks
    
    role&.permissions&.exists?(
      resource: resource,
      action: [action, 'manage']
    )
  end
end
