require "test_helper"

class BookmarkTest < ActiveSupport::TestCase
  test "valid bookmark" do
    bookmark = Bookmark.new(user: users(:admin_user), manga: mangas(:naruto))
    assert bookmark.valid?
  end

  test "invalid without user" do
    bookmark = Bookmark.new(manga: mangas(:naruto))
    assert_not bookmark.valid?
  end

  test "invalid without manga" do
    bookmark = Bookmark.new(user: users(:admin_user))
    assert_not bookmark.valid?
  end

  test "user cannot bookmark the same manga twice" do
    duplicate = Bookmark.new(user: users(:alice), manga: mangas(:naruto))
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  test "same manga can be bookmarked by different users" do
    bookmark = Bookmark.new(user: users(:bob), manga: mangas(:naruto))
    assert bookmark.valid?
  end
end
