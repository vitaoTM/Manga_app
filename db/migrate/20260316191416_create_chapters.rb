class CreateChapters < ActiveRecord::Migration[8.1]
  def change
    create_table :chapters do |t|
      t.references :manga, null: false, foreign_key: true
      t.decimal :number, null: false, precision: 6, scale: 1
      t.string :title
      t.text :notes
      t.integer :views_count, null: false, default: 0
      t.datetime :published_at

      t.timestamps
    end

    add_index :chapters, [ :manga_id, :number ], unique: true
    add_index :chapters, :published_at
  end
end
