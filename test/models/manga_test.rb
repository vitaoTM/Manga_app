require "test_helper"

class MangaTest < ActiveSupport::TestCase
  test "valid with title and author" do
    manga = Manga.new(title: "One Piece", author: "Oda", status: :ongoing, genre: :shounen)
    assert manga.valid?
  end

  test "invalid without title" do
    manga = Manga.new(author: "Oda")
    assert_not manga.valid?
    assert_includes manga.errors[:title], "can't be blank"
  end

  test "invalid without author" do
    manga = Manga.new(title: "One Piece")
    assert_not manga.valid?
    assert_includes manga.errors[:author], "can't be blank"
  end

  test "status enum uses prefix" do
    assert mangas(:naruto).status_ongoing?
    assert mangas(:bleach).status_completed?
  end

  test "genre enum uses prefix" do
    assert mangas(:naruto).genre_shounen?
    assert_not mangas(:naruto).genre_seinen?
  end

  test "latest_chapter returns highest numbered chapter" do
    assert_equal chapters(:naruto_ch2), mangas(:naruto).latest_chapter
  end

  test "total_chapters counts all chapters" do
    assert_equal 2, mangas(:naruto).total_chapters
  end

  test "by_latest orders newest first" do
    results = Manga.by_latest.to_a
    assert results.first.created_at >= results.last.created_at
  end

  test "destroying manga cascades to chapters" do
    manga = mangas(:naruto)
    chapter_ids = manga.chapters.pluck(:id)
    manga.destroy
    assert_empty Chapter.where(id: chapter_ids)
  end

  test "has many tags through manga_tags" do
    assert_includes mangas(:naruto).tags, tags(:action)
    assert_includes mangas(:naruto).tags, tags(:romance)
  end
end
