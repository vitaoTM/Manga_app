class ChaptersController < ApplicationController
  before_action :set_manga
  before_action :set_chapter
  before_action :set_chapters
  # before_action :require_admin!, only: [ :new, :create, :edit, :update, :destroy ]


  def index
    @chapters = Manga.find(params[:manga_id]).chapters
  end

  def show
    @pages = @chapter.pages.ordered
    @prev_chapter = @chapter.prev_chapter
    @next_chapter = @chapter.next_chapter

    @chapter.increment!(:views_count)
    @manga.increment!(:views_count)

    if user_signed_in?
      ReadingProgress.record!(
        user: current_user,
        manga: @manga,
        chapter: @chapter,
        page_number: 1
      )
    end
  end

  private

  def set_manga
    @manga = Manga.find(params[:manga_id])
  end

  def set_chapter
    @chapter = @manga.chapters.find_by(number: params[:id])
  end

  def set_chapters
    @chapters = Manga.find(params[:manga_id]).chapters
  end
end
