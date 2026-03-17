class Chapter < ApplicationRecord
  belongs_to :manga
  has_many :pages,  -> { order { :number } }, dependent: :destroy

  validates :number, presence: true, numericality: { greater_than: 0 }, uniqueness: { scope: :manga_id }
  scope :ordered, -> { order { :number } }
  scope :published, -> { where.not(published_at: nil).where("published_at <= ?", Time.current) }

  def display_title
    title.present? ? "Ch. #{number} - #{title}" : "Chapter #{number}"
  end

  def next_chapter
    manga.chapters.where("number > ?", number).order(:number).first
  end

  def prev_chapter
    manga.chapters.where("number < ?", number).order(:number).last
  end
end
