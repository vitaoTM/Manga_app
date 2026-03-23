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
      attach_pages if params.dig(:page, :image).present?
      redirect_to manga_chapter_path(@manga, @chapter.number),
        notice: "Chapter added"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @chapter.update(chapter_params)
      attach_pages if params.dig(:page, :image).present?
      redirect_to manga_chapter_path(@manga, @chapter.number),
        notice: "Chapter updated"
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

  def attach_pages
    images = Array(params.dig(:page, :image))
    next_number = (@chapter.pages.maximum(:number) || 0) + 1

    images.each_with_index do |image, i|
      page = @chapter.pages.build(number: next_number + 1)
      page.image.attach(image)
      page.save
    end
  end

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
