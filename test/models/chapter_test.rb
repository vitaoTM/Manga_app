require "test_helper"

class ChapterTest < ActiveSupport::TestCase
  test "valid with number and manga" do
    chapter = Chapter.new(manga: mangas(:naruto), number: 99)
    assert chapter.valid?
  end

  test "invalid without number" do
    chapter = Chapter.new(manga: mangas(:naruto))
    assert_not chapter.valid?
    assert_includes chapter.errors[:number], "can't be blank"
  end

  test "number must be >= 0" do
    chapter = Chapter.new(manga: mangas(:naruto), number: -1)
    assert_not chapter.valid?
  end

  test "number must be unique per manga" do
    duplicate = Chapter.new(manga: mangas(:naruto), number: 1.0)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:number], "has already been taken"
  end

  test "same number allowed in different manga" do
    chapter = Chapter.new(manga: mangas(:berserk), number: 99)
    assert chapter.valid?
  end

  test "ordered scope sorts by number asc" do
    numbers = mangas(:naruto).chapters.ordered.pluck(:number)
    assert_equal numbers.sort, numbers
  end

  test "published scope excludes future chapters" do
    published = Chapter.published.to_a
    assert_includes published, chapters(:naruto_ch1)
    assert_not_includes published, chapters(:bleach_future)
  end

  test "display_title with title" do
    assert_equal "Ch. 1.0 - Enter Naruto", chapters(:naruto_ch1).display_title
  end

  test "display_title without title" do
    ch = Chapter.new(manga: mangas(:naruto), number: 50)
    assert_equal "Chapter 50.0", ch.display_title
  end

  test "next_chapter returns the next one" do
    assert_equal chapters(:naruto_ch2), chapters(:naruto_ch1).next_chapter
  end

  test "prev_chapter returns the previous one" do
    assert_equal chapters(:naruto_ch1), chapters(:naruto_ch2).prev_chapter
  end

  test "next_chapter returns nil at the end" do
    assert_nil chapters(:naruto_ch2).next_chapter
  end

  test "url_number drops .0 suffix" do
    assert_equal "1", chapters(:naruto_ch1).url_number
  end
end
