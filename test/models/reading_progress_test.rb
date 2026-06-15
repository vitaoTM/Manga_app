require "test_helper"

class ReadingProgressTest < ActiveSupport::TestCase
  test "valid reading progress" do
    progress = ReadingProgress.new(
      user: users(:admin_user),
      manga: mangas(:naruto),
      chapter: chapters(:naruto_ch1),
      page_number: 1
    )
    assert progress.valid?
  end

  test "page_number must be greater than 0" do
    progress = ReadingProgress.new(
      user: users(:admin_user),
      manga: mangas(:naruto),
      chapter: chapters(:naruto_ch1),
      page_number: 0
    )
    assert_not progress.valid?
    assert_includes progress.errors[:page_number], "must be greater than 0"
  end

  test "user can only have one progress per manga" do
    duplicate = ReadingProgress.new(
      user: users(:alice),
      manga: mangas(:naruto),
      chapter: chapters(:naruto_ch1),
      page_number: 1
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  test "record! created a new progress" do
    progress = ReadingProgress.record!(
      user: users(:admin_user),
      manga: mangas(:bleach),
      chapter: chapters(:bleach_ch1),
      page_number: 3
    )
    assert progress.persisted?
    assert_equal 3, progress.page_number
  end

  test "record! updates existing progress" do
    ReadingProgress.record!(
      user: users(:alice),
      manga: mangas(:naruto),
      chapter: chapters(:naruto_ch2),
      page_number: 10
    )
    progress = users(:alice).progress_for(mangas(:naruto))
    assert_equal 10, progress.page_number
    assert_equal chapters(:naruto_ch2), progress.chapter
  end
end
