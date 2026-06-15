require "test_helper"

class PageTest < ActiveSupport::TestCase
  test "invalid without number" do
    page = Page.new(chapter: chapters(:naruto_ch1))
    assert_not page.valid?
    assert_includes page.errors[:number], "can't be blank"
  end

  test "number must be an integer" do
    page = Page.new(chapter: chapters(:naruto_ch1), number: 1.5)
    assert_not page.valid?
    assert_includes page.errors[:number], "must be an integer"
  end

  test "number must be greater than 0" do
    page = Page.new(chapter: chapters(:naruto_ch1), number: 0)
    assert_not page.valid?
    assert_includes page.errors[:number], "must be greater than 0"
  end

  test "number must be unique per chapter" do
    page = Page.new(chapter: chapters(:naruto_ch1), number: 1)
    assert_not page.valid?
    assert_includes page.errors[:number], "has already been taken"
  end

  test "same number allowed in different chapters" do
    page = Page.new(chapter: chapters(:naruto_ch2), number: 1)
    assert_not page.valid?
    assert_not_includes page.errors[:number], "has already been taken"
  end

  test "ordered scope sorts by number asc" do
    numbers = chapters(:naruto_ch1).pages.ordered.pluck(:number)
    assert_equal numbers.sort, numbers
  end
end
