class TagsController < ApplicationController
  before_action :set_tag,        only: [ :show, :edit, :update, :destroy ]
  before_action :require_admin!, only: [ :new, :create, :edit, :update, :destroy ]

  def index
    @tags = Tag.alphabetical.includes(:mangas)
  end

  def show
    @mangas = @tag.mangas.by_latest
  end

  def new
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(tag_params)
    if @tag.save
      redirect_to tags_path, notice: "Tag '#{@tag.name}' created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @tag.update(tag_params)
      redirect_to tags_path, notice: "Tag updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tag.destroy
    redirect_to tags_path, notice: "Tag deleted."
  end

  private

  def set_tag
    @tag = Tag.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name)
  end
end
