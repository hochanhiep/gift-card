require "rails_helper"

RSpec.describe Reports::ByBrand do
  let(:october) { Time.utc(2026, 10, 10) }
  let(:range)   { Time.utc(2026, 10, 1)..Time.utc(2026, 10, 31).end_of_day }

  let(:highlands) { create(:brand, name: "Highlands Coffee") }
  let(:starbucks) { create(:brand, name: "Starbucks") }

  def card(brand, denomination, **options)
    product = create(:product, brand: brand, denomination: denomination)
    create(:card, product: product, payout_rate: 10, created_at: october, **options)
  end

  it "totals cards per brand, ordered by name" do
    card(starbucks, 50)
    card(starbucks, 30, state: :cancelled, cancelled_at: Time.current)
    card(highlands, 20)

    expect(described_class.execute(range, {})).to eq([
      {
        id: highlands.id, name: "Highlands Coffee",
        spending: { cards: 1, amount: 20, payout: 2 },
        cancellations: { cards: 0, amount: 0 }
      },
      {
        id: starbucks.id, name: "Starbucks",
        spending: { cards: 1, amount: 50, payout: 5 },
        cancellations: { cards: 1, amount: 30 }
      }
    ])
  end

  it "leaves out brands without cards in the range" do
    card(highlands, 20, created_at: Time.utc(2026, 9, 30))
    create(:brand, name: "Starbucks")

    expect(described_class.execute(range, {})).to be_empty
  end

  it "counts every card without a range" do
    card(highlands, 20, created_at: Time.utc(2025, 1, 1))

    expect(described_class.execute(nil, {}).sole[:spending][:cards]).to eq(1)
  end

  it "only returns the brand given by brand_id" do
    card(highlands, 20)
    card(starbucks, 50)

    report = described_class.execute(range, { brand_id: starbucks.id.to_s })

    expect(report.pluck(:name)).to eq([ "Starbucks" ])
  end
end
