class MangasController < ApplicationController
  # before_action :set_manga, only: [ :show,  :update, :destroy ]

  def index
    mangas = Manga.all
  end

  def show
  end

  def create
    @manga = Manga.new(manga_params)
    if @manga.save
      redirec_to @manga, notice: "Manga created."
    else
      render :new, status: :unprocessable_entity
    end

    def edit
    end

    def update
      if @manga.update(manga_params)
        redirec_to @manga, notice: "Manga updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @manga.destroy
      redirec_to mangas_path, notice: "Manga deleted."
    end
  end

  private

  def set_manga
    @manga = Manga.find(params[:id])
  end

  def manga_params
    params.require(:manga)
      .permit(:title, :author, :description, :genre, :status, :cover_image)
  end
end
