class Donation < ApplicationRecord
  belongs_to :user, optional: true

  validates :amount_cents, numericality: { greater_than: 0 }
  validates :currency, presence: true

  scope :succeeded, -> { where(status: "succeeded") }
  scope :recent, -> { order(created_at: :desc) }

  def amount_display
    "#{currency.upcase} #{format('%.2f', amount_cents / 100.00)}"
  end

  def succeeded?
    status == "succeeded"
  end

  def pending?
    status == "pending"
  end
end
