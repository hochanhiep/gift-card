require "rails_helper"

RSpec.describe Reports::CardTotals do
  let(:client) { create(:user, :client) }

  def card(denomination, created_at: Time.utc(2026, 10, 10), payout_rate: 10, **options)
    create(:card, client: client, denomination: denomination, payout_rate: payout_rate,
                  created_at: created_at, **options)
  end

  def totals(range = nil)
    described_class.execute(client.cards, range)
  end

  it "splits spending and cancellations" do
    card(50)
    card(20)
    card(30, state: :cancelled, cancelled_at: Time.current)

    expect(totals).to eq(
      spending: { cards: 2, amount: 70, payout: 7 },
      cancellations: { cards: 1, amount: 30 }
    )
  end

  it "uses the payout rate saved on each card" do
    card(100, payout_rate: 10)
    card(100, payout_rate: 50)

    expect(totals[:spending][:payout]).to eq(60)
  end

  it "rounds the payout once, not per card" do
    3.times { card(1, payout_rate: 0.5) }

    expect(totals[:spending][:payout]).to eq(0.02)
  end

  it "counts only cards issued inside the range" do
    card(50, created_at: Time.utc(2026, 9, 30, 23, 59))
    card(20, created_at: Time.utc(2026, 10, 31, 23, 59))
    card(30, created_at: Time.utc(2026, 11, 1))

    range = Time.utc(2026, 10, 1)..Time.utc(2026, 10, 31).end_of_day

    expect(totals(range)[:spending]).to include(cards: 1, amount: 20)
  end

  it "returns zeros when there are no cards" do
    expect(totals).to eq(
      spending: { cards: 0, amount: 0, payout: 0 },
      cancellations: { cards: 0, amount: 0 }
    )
  end
end
