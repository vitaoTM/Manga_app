class MangasController < ApplicationController
  before_action :set_manga, only: [ :show, :edit, :update, :destroy ]
  before_action :require_admin!, only: [ :new, :create, :edit, :update, :destroy ]

  def index
    @mangas = Manga.order(created_at: :desc)
    # change latter maybe for updated latter
  end

  def show
    @chapters = @manga.chapters.published.ordered
  end

  def new
    @manga = Manga.new
  end

  def create
    @manga = Manga.new(manga_params)
    if @manga.save
      redirect_to @manga, notice: "Manga created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @manga.update(manga_params)
      redirect_to @manga, notice: "Manga updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @manga.destroy
    redirect_to mangas_path, notice: "Manga deleted."
  end

  private

  def set_manga
    @manga = Manga.find(params[:id])
  end

  def manga_params
    params.require(:manga)
      .permit(:title, :author, :description, :genre, :status, :cover_image, tag_ids: [])
  end
end
