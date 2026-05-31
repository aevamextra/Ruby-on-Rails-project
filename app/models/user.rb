class User < ApplicationRecord
  has_secure_password
  validates :email, presence: true, uniqueness: true

  enum :role, { user: 0, admin: 1, owner: 2 }

  has_many :projects, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :comments, dependent: :destroy
end
