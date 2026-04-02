class DonationsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create ]

  def new
    @amounts = [ 500, 1000, 2000, 5000 ]
  end

  def create
    amount_cents = params[:amount_cents].to_i

    if amount_cents < 100
      redirect_to new_donation_path, alert: "Minimum donation is R$ 1.00."
      return
    end

    donation = current_user.donations.create!(
      amount_cents: amount_cents,
      currency:     "brl",
      status:       "pending",
      message:      params[:message]
    )

    session = Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      line_items: [ {
        price_data: {
          currency:     "brl",
          unit_amount:  amount_cents,
          product_data: {
            name:        "Donation — Manga App",
            description: donation.message.presence || "Thank you for your support!"
          }
        },
        quantity: 1
      } ],
      mode:        "payment",
      success_url: success_donations_url(session_id: "{CHECKOUT_SESSION_ID}"),
      cancel_url:  cancel_donations_url,
      metadata: {
        donation_id: donation.id,
        user_id:     current_user.id
      }
    )

    donation.update!(stripe_session_id: session.id)

    redirect_to session.url,
      allow_other_host: true,
      status: :see_other

  rescue Stripe::StripeError => e
    redirect_to new_donation_path, alert: "Payment error: #{e.message}"
  end

  def success
    # Stripe redirects here after payment
    # DO NOT mark as succeeded here — wait for webhook
    # The webhook is the source of truth
    @session_id = params[:session_id]
  end

  def cancel
    # User clicked "Back" on Stripe Checkout
  end
end
