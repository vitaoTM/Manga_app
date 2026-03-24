class MangaTag < ApplicationRecord
  belongs_to :manga
  belongs_to :tag

  validates :manga_id, uniqueness: { scope: :tag_id }
end
