class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    @manga_count = Manga.count
    @chapter_count = Chapter.count
    @user_count = User.count
    @recent_mangas = Manga.order(created_at: :desc)# .limit(5)
    @donation_total   = Donation.succeeded.sum(:amount_cents)
    @donation_count   = Donation.succeeded.count
    @recent_donations = Donation.succeeded.includes(:user).order(created_at: :desc).limit(10)
  end
end
