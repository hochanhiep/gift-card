require "rails_helper"

RSpec.describe Cards::Cancel do
  let(:client) { create(:user, :client) }
  let(:card)   { create(:card, client: client) }

  def cancel(card_id: card.id)
    described_class.execute(client: client, card_id: card_id)
  end

  it "cancels an issued card" do
    freeze_time do
      result = cancel

      expect(result).to be_success
      expect(result.card.reload).to have_attributes(state: "cancelled", cancelled_at: Time.current)
    end
  end

  it "refuses a card that is already cancelled" do
    card.update!(state: :cancelled, cancelled_at: 1.day.ago)

    expect(cancel.error).to eq(:already_cancelled)
    expect(card.reload.cancelled_at).to be_within(1.second).of(1.day.ago)
  end

  it "does not find another client's card" do
    other_card = create(:card)

    expect(cancel(card_id: other_card.id).error).to eq(:card_not_found)
    expect(other_card.reload).to be_issued
  end

  it "does not find an unknown card" do
    expect(cancel(card_id: 0).error).to eq(:card_not_found)
  end
end
