class AddCascadeDeleteToPages < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :pages, :chapters
    add_foreign_key :pages, :chapters, on_delete: :cascade  # foreign, not foreing
  end
end
