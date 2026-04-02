FactoryBot.define do
  factory :donation do
    user { nil }
    amount_cents { 1 }
    currency { "MyString" }
    status { "MyString" }
    stripe_session_id { "MyString" }
    stripe_payment_intent_id { "MyString" }
    message { "MyText" }
  end
end
