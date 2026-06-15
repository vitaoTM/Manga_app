require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "valid tag" do
    tag = Tag.new(name: "horror")
    assert tag.valid?
  end

  test "invalid withou name" do
    tag = Tag.new
    assert_not tag.valid?
    assert_includes tag.errors[:name], "can't be blank"
  end

  test "name must be unique case-insensitively" do
    duplicate = Tag.new(name: "Action")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "before_save downcases name" do
    tag = Tag.create!(name: "horror")
    assert_equal "horror", tag.name
  end

  test "before_save strips whitespace" do
    tag = Tag.create!(name: " thriller ")
    assert "thriller", tag.name
  end

  test "alphabetical scope orders by name asc" do
    names = Tag.alphabetical.pluck(:name)
    assert_equal names.sort, names
  end

  test "has many mangas through manga_tags" do
    assert_includes tags(:action).mangas, mangas(:naruto)
    assert_includes tags(:action).mangas, mangas(:bleach)
  end
end
