require "stripe"
Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
Rails.logger.info "Stripe key loaded: #{Stripe.api_key.present?}"
Rails.logger.info "Webhook secret loaded: #{ENV['STRIPE_WEBHOOK_SECRET'].present?}"
