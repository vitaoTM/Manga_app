class ChaptersController < ApplicationController
  before_action :set_manga
  before_action :set_chapter
  # before_action :require_admin!, only: [ :new, :create, :edit, :update, :destroy ]


  def new
    @chapter = @manga.chapters.build
  end

  def create
    @chapter = @manga.chapters.build(chapter_params)
    if @chapter.save
      redirect_to manga_chapter_path(@manga, @chapter.number)
    else
      render :new, status: :unprocessable_entity
    end
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

  def chapter_params
    params.require(:chapter).permit(:number, :title, :notes, :published_at)
  end
end
