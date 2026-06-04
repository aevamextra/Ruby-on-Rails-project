class User < ApplicationRecord
  has_secure_password
  validates :email, presence: true, uniqueness: true

  belongs_to :role, optional: true

  has_many :projects, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :comments, dependent: :destroy

  def owner?
    role&.name == 'owner'
  end

  def admin?
    role&.name == 'admin'
  end

  def user?
    role&.name == 'user'
  end
end
