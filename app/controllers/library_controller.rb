  class LibraryController < ApplicationController
    before_action :authenticate_user!

    def show
      @bookmarks = current_user.bookmarks.includes(manga: [ :ratings, cover_image_attachment: :blob ]).order(created_at: :desc)

      @progresses = current_user.reading_progresses.where(manga_id: @bookmarks.map(&:manga_id)).index_by(&:manga_id)
    end
  end
