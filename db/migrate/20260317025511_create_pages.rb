class CreatePages < ActiveRecord::Migration[8.1]
  def change
    create_table :pages do |t|
      t.references :chapter, null: false, foreign_key: true
      t.integer :number, null: false

      t.timestamps
    end

    add_index :pages, [ :chapter_id, :number ], unique: true
  end
end
