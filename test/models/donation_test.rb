require "test_helper"

class DonationTest < ActiveSupport::TestCase
  test "valid donation" do
    donation = Donation.new(user: users(:alice), amount_cents: 500, currency: "brl")
    assert donation.valid?
  end

  test "invalid without currency" do
    donation = Donation.new(user: users(:alice), amount_cents: 500, currency: nil)
    assert_not donation.valid?
    assert_includes donation.errors[:currency], "can't be blank"
  end

  test "amount_cents must be greater than 0" do
    donation = Donation.new(user: users(:alice), amount_cents: 0, currency: "brl")
    assert_not donation.valid?
    assert_includes donation.errors[:amount_cents], "must be greater than 0"
  end

  test "secceeded scope returns only succeeded donations" do
    results = Donation.succeeded.to_a
    assert_includes results, donations(:bob_succeeded)
    assert_not_includes results, donations(:alice_pending)
  end

  test "recent scope orders by created_at desc" do
    results = Donation.recent.to_a
    assert results.first.created_at >= results.last.created_at
  end

  test "amount_display formats correctly" do
    assert_equal "BRL 10.00", donations(:alice_pending).amount_display
  end

  test "succeeded? returns true for succeeded status" do
    assert donations(:bob_succeeded).succeeded?
  end

  test "pending? returns true for pending status" do
    assert donations(:alice_pending).pending?
  end

  test "pending? returns false for succeeded status" do
    assert_not donations(:bob_succeeded).pending?
  end
end
