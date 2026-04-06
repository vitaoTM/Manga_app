module Webhooks
  class StripeController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      payload = request.body.read

      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]

      begin
        event = Stripe::Webhook.construct_event(
          payload, sig_header, ENV["STRIPE_WEBHOOK_SECRET"]
        )
      rescue JSON::ParserError
        render json: { error: "Invalid payload" }, status: :bad_request and return
      rescue Stripe::SignatureVerificationError
        render json: { error: "Invalid signature" }, status: :bad_request and return
      end

      case event.type
      when "checkout.session.completed"
        handle_checkout_completed(event.data.object)
      when "payment_intent.payment_failed"
        handle_payment_failed(event.data.object)
      end
      render json: { received: true }
    end

    private

    def handle_checkout_completed(session)
      donation = Donation.find_by(stripe_session_id: session.id)
      return unless donation  # test triggers won't match a real donation — that's fine

      donation.update!(
        status:                   "succeeded",
        stripe_payment_intent_id: session.payment_intent  # can be nil in test fixtures
      )
    end

    def handle_payment_failed(payment_intent)
      donation_id = payment_intent.metadata.donation_id
      donation = Donation.find_by(id: donation_id)
      return unless donation

      donation.update!(
        status: "failed",
        stripe_payment_intent_id: payment_intent.id
      )
    end
  end
end
