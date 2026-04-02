class CreateDonations < ActiveRecord::Migration[8.1]
  def change
    create_table :donations do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :amount_cents, null: false
      t.string :currency, null: false, default: 'brl'
      t.string :status, null: false, default: 'pending'
      t.string :stripe_session_id
      t.string :stripe_payment_intent_id
      t.text :message

      t.timestamps
    end

    add_index :donations, :stripe_session_id, unique: true
    add_index :donations, :status
  end
end
