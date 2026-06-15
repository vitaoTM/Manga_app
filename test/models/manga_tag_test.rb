require "test_helper"

class MangaTagTest < ActiveSupport::TestCase
  test "valid manga_tag" do
    manga_tag = MangaTag.new(manga: mangas(:berserk), tag: tags(:action))
    assert manga_tag.valid?
  end

  test "invalid without manga" do
    manga_tag = MangaTag.new(tag: tags(:action))
    assert_not manga_tag.valid?
  end

  test "invalid without tag" do
    manga_tag = MangaTag.new(manga: mangas(:naruto))
    assert_not manga_tag.valid?
  end

  test "manga and tag combination must be unique" do
    duplicate = MangaTag.new(manga: mangas(:naruto), tag: tags(:action))
    assert_not duplicate.valid?
  end

  test "same tag can be added to different mangas" do
    manga_tag = MangaTag.new(manga: mangas(:berserk), tag: tags(:romance))
    assert manga_tag.valid?
  end
end
