class CreateReadingProgresses < ActiveRecord::Migration[8.1]
  def change
    create_table :reading_progresses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :manga, null: false, foreign_key: true
      t.references :chapter, null: false, foreign_key: true
      t.integer :page_number, null: false, default: 1

      t.timestamps
    end

    add_index :reading_progresses, [ :user_id, :manga_id ], unique: true
  end
end
