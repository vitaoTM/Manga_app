class ReadingProgressesController < ApplicationController
  before_action :authenticate_user!

  def upsert
    manga = Manga.find(params[:manga_id])
    chapter = manga.chapters.find(params[:chapter_id])

    progress = ReadingProgress.record!(
      user: current_user,
      manga: manga,
      chapter: chapter,
      page_number: params[:page_number].to_i
    )

    render json: { status: "ok", page_number: progress.page_number }
  rescue ActiveRecord::RecordNotFound
    reder json: { error: "Not fount" }, status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
