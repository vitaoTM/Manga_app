require "test_helper"

class RatingTest < ActiveSupport::TestCase
  test "valid ration" do
    rating = Rating.new(user: users(:admin_user), manga: mangas(:naruto), score: 8)
    assert rating.valid?
  end

  test "invaldi without score" do
    rating = Rating.new(user: users(:admin_user), manga: mangas(:naruto))
    assert_not rating.valid?
    assert_includes rating.errors[:score], "can't be blank"
  end

  test "score must be at least 1" do
    rating = Rating.new(user: users(:admin_user), manga: mangas(:naruto), score: 0)
    assert_not rating.valid?
    assert_includes rating.errors[:score], "must be greater than or equal to 1"
  end

  test "score must be at most 10" do
    rating = Rating.new(user: users(:admin_user), manga: mangas(:naruto), score: 11)
    assert_not rating.valid?
    assert_includes rating.errors[:score], "must be less than or equal to 10"
  end

  test "user cannot rate the same manga twice" do
    duplicate = Rating.new(user: users(:alice), manga: mangas(:naruto), score: 5)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  test "saving a rating updates manga rating" do
    manga = mangas(:berserk)
    Rating.create!(user: users(:alice), manga: manga, score: 9)
    assert_equal 9.0, manga.reload.rating.to_i
  end

  test "destroying a rating recalculates manga rating" do
    manga = mangas(:berserk)
    rating = Rating.create!(user: users(:alice), manga: manga, score: 9)
    assert_equal 9.0, manga.reload.rating.to_i
    rating.destroy
    assert_equal 10.0, manga.reload.rating.to_i
  end
end
