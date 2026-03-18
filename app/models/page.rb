class Page < ApplicationRecord
  has_one_attached :image
  belongs_to :chapter

  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }, uniqueness: { scope: chapter_id }
  validates :image, presence: true
  scope :ordered, -> { order(:number) }
end
