class PagesController < ApplicationController
  before_action :set_manga, only: [ :show, :new, :create, :destroy ]
  before_action :set_chapter, only: [ :show, :new, :create, :destroy ]
  before_action :set_page, only: [ :show, :destroy ]
  before_action :require_admin!, only: [ :new, :create, :destroy ]

  def show
    @next_page = @chapter.pages.where("number < ?", @page.number).order(:number).last
    @prev_page = @chapter.pages.where("number > ?", @page.number).order(:number).first
  end

  def new
    @page = @chapter.pages.build
  end

  def create
    images = Array(params[:images]).reject { |f| f.blank? || f.is_a?(String) }

    if images.empty?
      flash.now[:alert] = "Please select at least one image."
      @page = @chapter.pages.build
      # @page.errors.add(:images, "Must select")
      render :new, status: :unprocessable_entity and return
    end

    next_number = (@chapter.pages.maximum(:number) || 0) + 1

    ActiveRecord::Base.transaction do
     images.each_with_index.map do |img, i|
        page = @chapter.pages.build(number: next_number + i)
        page.image.attach(img)
        page.save!
      end

      redirect_to manga_chapter_path(@manga, @chapter.url_number),
        notice: "#{images.size} page(s) uploaded."

    rescue ActiveRecord::RecordInvalid => e
      flash.now[:alert] = "Upload Failed: #{e.message}"
      @page = @chapter.pages.build
      render :new, status: :unprocessable_entity
    end

    def destroy
      @page.image.purge
      @page.destroy
      redirect_to edit_manga_chapter_path(@manga, @chapter.url_number),
        notice: "Page #{@page.number} deleted."
    end
    # if pages.all?(&:save)
    #   redirect_to manga_chapter_path(@manga, @chapter.number), notice: "#{pages.size} page(s) uploaded"
    # else
    #   @page = @chapter.pages.build
    #   flash.now[:alert] = "Some pages failed to upload"
    #   render :new, status: :unprocessable_entity
    # end
  end

  private

  def set_manga
    @manga = Manga.find(params[:manga_id])
  end

  def set_page
    @page = @chapter.pages.find_by!(number: params[:id])
  end

  def set_chapter
    @chapter = @manga.chapters.find_by!(number: params[:chapter_id])
  end
end
