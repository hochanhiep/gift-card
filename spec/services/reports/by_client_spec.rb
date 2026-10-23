require "rails_helper"

RSpec.describe Reports::ByClient do
  let(:october) { Time.utc(2026, 10, 10) }
  let(:range)   { Time.utc(2026, 10, 1)..Time.utc(2026, 10, 31).end_of_day }

  let(:dwight)  { create(:user, :client, email: "dwight@example.com") }
  let(:michael) { create(:user, :client, email: "michael@example.com") }

  def card(client, denomination, **options)
    create(:card, client: client, denomination: denomination, payout_rate: 10, created_at: october, **options)
  end

  it "totals cards per client, ordered by email" do
    card(michael, 50)
    card(michael, 30, state: :cancelled, cancelled_at: Time.current)
    card(dwight, 20)

    expect(described_class.execute(range)).to eq([
      {
        id: dwight.id, email: "dwight@example.com",
        spending: { cards: 1, amount: 20, payout: 2 },
        cancellations: { cards: 0, amount: 0 }
      },
      {
        id: michael.id, email: "michael@example.com",
        spending: { cards: 1, amount: 50, payout: 5 },
        cancellations: { cards: 1, amount: 30 }
      }
    ])
  end

  it "leaves out clients without cards in the range" do
    card(dwight, 20, created_at: Time.utc(2026, 11, 1))
    create(:user, :client, email: "michael@example.com")

    expect(described_class.execute(range)).to be_empty
  end
end
