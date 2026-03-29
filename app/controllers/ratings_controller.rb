class RatingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_rating, only: [ :update, :destroy ]

  def create
    @manga = Manga.find(params[:rating][:manga_id])
    @rating = current_user.ratings.find_or_initialize_by(manga: @manga)
    @rating.score = params[:rating][:score]

    if @rating.save
      redirect_back fallback_location: @manga,
                    notice: "Rated #{@rating.score}/10."
    else
      redirect_back fallback_location: @manga,
                    alert: @rating.errors.full_messages.join(", ")
    end
  end

  def update
    if @rating.update(score: params[:rating][:score])
      redirect_back fallback_location: @rating.manga,
                    notice: "Rating updated to #{@rating.score}/10."
    else
      redirect_back fallback_location: @rating.manga,
                    alert: @rating.errors.full_messages.join(", ")
    end
  end

  def destroy
    manga = @rating.manga
    @rating.destroy
    redirect_back fallback_location: manga,
                  notice: "Rating removed."
  end

  private

  def set_rating
    @rating = current_user.ratings.find(params[:id])
  end

  def ratings_params
    params.require(:ratings).permit(:manga_id, :rating, :score)
  end
end
