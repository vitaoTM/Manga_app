class ReadingProgress < ApplicationRecord
  belongs_to :user
  belongs_to :manga
  belongs_to :chapter

  validates :user_id, uniqueness: { scope: :manga_id }
  validates :page_number, numericality: { only_integer: true, greater_than: 0 }

  def self.record!(user:, manga:, chapter:, page_number:)
    progress = find_or_initialize_by(user: user, manga: manga)
    progress.update!(chapter: chapter, page_number: page_number)
    progress
  end
end
