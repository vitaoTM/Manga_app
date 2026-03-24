class Tag < ApplicationRecord
  has_many :manga_tags, dependent: :destroy
  has_many :mangas, through: :manga_tags

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  before_save { self.name = name.downcase.strip }
  scope :alphabetical, -> { order(:name) }
end
