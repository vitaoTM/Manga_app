module Admin
  class DashboardController < BaseController
    def admin
      @manga_count = Manga.count
      @chapter_count = Chapter.count
      @user_count = User.count
      @recent_mangas = Manga.order(created_at: :desc).limit(5)
    end
  end
end
