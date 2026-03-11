class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable
  # :configurable, :lockable, :trackable

  validates :username,
            presence: true, uniqueness: { case_sensitive: false },
            length: { minimum: 3, maximum: 15 },
            format: { with: /\A[a-z0-9_]+\z/i, message: "can only contain letters, numbers and underscores" }

  has_one_attached :avatar
end
