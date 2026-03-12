class MangasController < ApplicationController
  def index
    mangas = Manga.all
  end

  def create
    @manga = Manga.new
  end
end
