require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user" do
    user = User.new(email: "new@example.com", username: "newuser", password: "password")
    assert user.valid?
  end

  test "invalid without username" do
    user = User.new(email: "new@example.com", password: "password")
    assert_not user.valid?
    assert_includes user.errors[:username], "can't be blank"
  end

  test "username too short" do
    user = User.new(email: "new@example.com", username: "ne", password: "password")
    assert_not user.valid?
    assert_includes user.errors[:username], "is too short (minimum is 3 characters)"
  end

  test "username too long" do
    user = User.new(email: "new@example.com", username: "ne" * 16, password: "password")
    assert_not user.valid?
    assert_includes user.errors[:username], "is too long (maximum is 15 characters)"
  end

  test "username invalid format" do
    user = User.new(email: "new@example.com", username: "not a valid user", password: "password")
    assert_not user.valid?
    assert_includes user.errors[:username], "can only contain letters, numbers and underscores"
  end

  test "username must be unique case-insensitively" do
    user = User.new(email: "other@example.com", username: "Alice", password: "password")
    assert_not user.valid?
    assert_includes user.errors[:username], "has already been taken"
  end

  test "rated? returns true when user has rated the manga" do
    assert users(:alice).rated?(mangas(:naruto))
  end

  test "rated? returns false when user has not rated the manga" do
    assert_not users(:alice).rated?(mangas(:bleach))
  end

  test "rating_for returns the correct rating" do
    rating = users(:alice).rating_for(mangas(:naruto))
    assert_equal ratings(:alice_naruto), rating
  end

                                                                                                      test "bookmarked? returns true when bookmarked" do
    assert users(:alice).bookmarked?(mangas(:naruto))
  end
                                                                                                      test "bookmarked? returns false when not bookmarked" do
    assert_not users(:alice).bookmarked?(mangas(:bleach))
  end

  test "progress_for returns the reading progress" do
    progress = users(:alice).progress_for(mangas(:naruto))
    assert_equal reading_progresses(:alice_naruto), progress
  end
end
