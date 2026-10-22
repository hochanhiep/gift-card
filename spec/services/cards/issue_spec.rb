require "rails_helper"

RSpec.describe Cards::Issue do
  let(:client)  { create(:user, :client, payout_rate: 12.5) }
  let(:brand)   { create(:brand) }
  let(:product) { create(:product, brand: brand, denomination: 100_000) }

  before { client.update!(product_ids: [ product.id ]) }

  def issue(product_id: product.id, key: "order-1")
    described_class.execute(client: client, product_id: product_id, idempotency_key: key)
  end

  it "issues a card with the product's denomination and the client's payout rate" do
    result = issue

    expect(result).to be_success
    expect(result.replayed).to be(false)
    expect(result.card).to have_attributes(client: client, product: product, denomination: 100_000, payout_rate: 12.5)
    expect(result.card.activation_number).to be_present
    expect(result.card.pin).to be_present
  end

  it "leaves the pin empty when the product does not need one" do
    product.update!(pin_required: false)

    expect(issue.card.pin).to be_nil
  end

  it "keeps the payout rate the card was issued with" do
    card = issue.card
    client.update!(payout_rate: 20)

    expect(card.reload.payout_rate).to eq(12.5)
  end

  describe "replay" do
    it "returns the same card for the same key and product" do
      card = issue.card
      result = issue

      expect(result.card).to eq(card)
      expect(result.replayed).to be(true)
      expect(Card.count).to eq(1)
    end

    it "replays even after the product was deactivated" do
      card = issue.card
      product.inactive!

      expect(issue.card).to eq(card)
    end

    it "refuses the key for another product" do
      issue
      other = create(:product, brand: brand)
      client.update!(product_ids: [ product.id, other.id ])

      result = issue(product_id: other.id)

      expect(result.error).to eq(:idempotency_key_reused)
      expect(Card.count).to eq(1)
    end

    it "does not share keys between clients" do
      issue
      other_client = create(:user, :client, product_ids: [ product.id ])

      result = described_class.execute(client: other_client, product_id: product.id, idempotency_key: "order-1")

      expect(result.replayed).to be(false)
      expect(Card.count).to eq(2)
    end

    it "replays the other request's card when it wins the race" do
      card = create(:card, client: client, product: product, idempotency_key: "order-1")
      service = described_class.new(client: client, product_id: product.id, idempotency_key: "order-1")
      allow(service).to receive(:existing_card).and_return(nil, card)

      result = service.execute

      expect(result.card).to eq(card)
      expect(result.replayed).to be(true)
    end
  end

  describe "refusals" do
    it "refuses a product the client has no access to" do
      result = issue(product_id: create(:product).id)

      expect(result.error).to eq(:product_not_found)
    end

    it "refuses an inactive product" do
      product.inactive!

      expect(issue.error).to eq(:product_unavailable)
    end

    it "refuses a product of an inactive brand" do
      brand.inactive!

      expect(issue.error).to eq(:product_unavailable)
    end

    it "creates no card when refused" do
      product.inactive!
      issue

      expect(Card.count).to eq(0)
    end
  end
end
