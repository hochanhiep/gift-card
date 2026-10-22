require "rails_helper"

RSpec.describe Catalog::Search do
  let(:client)    { create(:user, :client) }
  let(:starbucks) { create(:brand, name: "Starbucks") }
  let(:highlands) { create(:brand, name: "Highlands Coffee") }

  let!(:gift_100)   { create(:product, brand: starbucks, name: "Gift 100K", denomination: 100_000) }
  let!(:gift_200)   { create(:product, brand: starbucks, name: "Gift 200K", denomination: 200_000) }
  let!(:star_combo) { create(:product, brand: highlands, name: "Star Combo 50K", denomination: 50_000) }

  before { client.update!(product_ids: [ gift_100.id, gift_200.id, star_combo.id ]) }

  def search(filters = {})
    described_class.execute(client, filters)
  end

  it "returns the client's products sorted by name" do
    expect(search).to eq([ gift_100, gift_200, star_combo ])
  end

  it "hides products the client has no access to" do
    create(:product, brand: starbucks, name: "Gift 500K")

    expect(search).to eq([ gift_100, gift_200, star_combo ])
  end

  it "hides inactive products" do
    gift_200.inactive!

    expect(search).to eq([ gift_100, star_combo ])
  end

  it "hides products of an inactive brand" do
    starbucks.inactive!

    expect(search).to eq([ star_combo ])
  end

  describe "q" do
    it "matches product or brand names, ignoring case" do
      expect(search(q: "STAR")).to eq([ gift_100, gift_200, star_combo ])
    end

    it "matches only product names with search_in product" do
      expect(search(q: "star", search_in: "product")).to eq([ star_combo ])
    end

    it "matches only brand names with search_in brand" do
      expect(search(q: "star", search_in: "brand")).to eq([ gift_100, gift_200 ])
    end

    it "treats % as a plain character" do
      expect(search(q: "%")).to be_empty
    end
  end

  describe "denomination" do
    it "filters by min and max, both inclusive" do
      expect(search(min_denomination: "100000")).to eq([ gift_100, gift_200 ])
      expect(search(max_denomination: "100000")).to eq([ gift_100, star_combo ])
      expect(search(min_denomination: "100000", max_denomination: "100000")).to eq([ gift_100 ])
    end
  end
end
