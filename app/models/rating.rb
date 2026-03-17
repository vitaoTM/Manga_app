class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :manga

  validates :score, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }
  validates :user_id, uniqueness: { scope: :manga_id }

  after_save :recalculate_manga_rating
  after_destroy :recalculate_manga_rating

  private

  def recalculate_manga_rating
    manga.update_column(:rating, manga.ratings.average(:score)&.round(1) || 0.0)
  end
end
