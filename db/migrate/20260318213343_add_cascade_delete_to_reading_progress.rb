class AddCascadeDeleteToReadingProgress < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :reading_progresses, :chapters
    add_foreign_key    :reading_progresses, :chapters, on_delete: :cascade

    remove_foreign_key :reading_progresses, :mangas
    add_foreign_key    :reading_progresses, :mangas,   on_delete: :cascade
  end
end
