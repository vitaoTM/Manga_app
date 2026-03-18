class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable # :configurable, :lockable, :trackable

  validates :username,
            presence: true, uniqueness: { case_sensitive: false },
            length: { minimum: 3, maximum: 15 },
            format: { with: /\A[a-z0-9_]+\z/i, message: "can only contain letters, numbers and underscores" }

  has_one_attached :avatar

  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_mangas, through: :bookmarks, source: :manga
  has_many :ratings, dependent: :destroy
  has_many :reading_progresses, dependent: :destroy

  def progress_for(manga)
    reading_progresses.find_by(manga: manga)
  end

  def rated?(manga)
    ratings.exists?(manga: manga)
  end

  def rating_for(manga)
    ratings.find_by(manga: manga)
  end

  def bookmarked?(manga)
    bookmarks.exists?(manga: manga)
  end
end
