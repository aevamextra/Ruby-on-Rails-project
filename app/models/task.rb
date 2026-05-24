class Task < ApplicationRecord
  belongs_to :user, optional: true
  has_many :comments, dependent: :destroy

  validates :title, presence: {message:"Did you forgot to add Title?"}
  validates :description, presence: {message:"ooops! You forgot to add description..."}
  enum :status, [ :inprogress, :archived ,:done] ,default: :inprogress
  enum :priority, [ :high, :low ,:urgent] ,default: :low
end
