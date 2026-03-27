class Manga < ApplicationRecord
  has_one_attached :cover_image
  has_many :chapters, dependent: :destroy
  has_many :manga_tags, dependent: :destroy
  has_many :tags, through: :manga_tags
  has_many :bookmarks, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :reading_progresses, dependent: :destroy

  enum :status, {
    ongoing: 0,
    completed: 1,
    hiatus: 2,
    canceled: 3
  }, prefix: true

  enum :genre, {
    shounen: 0,
    shoujo: 1,
    seinen: 2,
    josei: 3,
    other: 99
  }, prefix: true

  scope :by_latest, -> { order(created_at: :desc) }
  validates :title, presence: true
  validates :author, presence: true
  # validates :status, presence: true
  # validates :genre, presence: true
  # validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }

  def latest_chapter
    chapters.order(number: :desc).first
  end

  def total_chapters
    chapters.count
  end

  def progress_for(manga)
    reading_progresses.find_by(manga: manga)
  end

  def caceled?
    self.status.value == "canceled"
  end

  def ongoing?
    self.status == "ongoing"
  end

  def hiatus?
    self.status == "hiatus"
  end

  def completed?
    self.stauts == "completed"
  end
end
