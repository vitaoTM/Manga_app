class PagesController < ApplicationController
  before_action :set_manga, only: [ :show, :new, :create ]
  before_action :set_chapter, only: [ :show, :new, :create ]
  before_action :require_admin!, only: [ :new, :create ]

  def show
    @page = @chapter.pages.find_by!(number: params[:id])
    @next_page = @chapter.pages.where("number < ?", @page.number).order(:number).last
    @prev_page = @chapter.pages.where("number > ?", @page.number).order(:number).first
  end

  def new
    @page = @chapter.pages.build
  end

  def create
    images = Array(params.dig(:page, :images))

    if images.empty?
      @page = @chapter.pages.build
      @page.errors.add(:images, "Must select")
      render :new, status: :unprocessable_entity and return
    end

    next_number = (@chapter.pages.maximum(:number) || 0) + 1

    pages = images.each_with_index.map do |img, i|
      page = @chapter.pages.build(number: next_number + i)
      page.image.attach(img)
      page
    end

    if pages.all?(&:save)
      redirect_to manga_chapter_path(@manga, @chapter.number), notice: "#{pages.size} page(s) uploaded"
    else
      @page = @chapter.pages.build
      flash.now[:alert] = "Some pages failed to upload"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_manga
    @manga = Manga.find(params[:manga_id])
  end

  def set_chapter
    @chapter = @manga.chapters.find_by!(number: params[:chapter_id])
  end
end
