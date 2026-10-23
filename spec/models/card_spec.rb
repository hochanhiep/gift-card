require "rails_helper"

RSpec.describe Card do
  describe "state" do
    it "can be cancelled" do
      card = create(:card)

      expect(card.update(state: :cancelled, cancelled_at: Time.current)).to be(true)
    end

    it "cannot go back to issued once cancelled" do
      card = create(:card, :cancelled)

      expect(card.update(state: :issued, cancelled_at: nil)).to be(false)
      expect(card.errors[:state]).to include("cannot change back to issued")
      expect(card.reload).to be_cancelled
    end
  end
end
