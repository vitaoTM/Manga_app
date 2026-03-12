class CreateMangas < ActiveRecord::Migration[8.1]
  def change
    create_table :mangas do |t|
      t.string :title,        null: false
      t.string :author,       null: false
      t.text :description
      t.integer :status,      null: false, default: 0
      t.integer :genre,       null: false, default: 0
      t.decimal :rating,      null: false, default: 0.0
      t.integer :views_count, null: false, default: 0

      t.timestamps
    end

    add_index :mangas, :title
    add_index :mangas, :status
    add_index :mangas, :genre
    add_index :mangas, :views_count
  end
end
