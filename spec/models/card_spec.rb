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

# == Schema Information
#
# Table name: cards
#
#  id                :bigint           not null, primary key
#  activation_number :string           not null
#  cancelled_at      :datetime
#  denomination      :decimal(10, 2)   not null
#  idempotency_key   :string           not null
#  payout_rate       :decimal(5, 2)    not null
#  pin               :text
#  state             :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  client_id         :bigint           not null
#  product_id        :bigint           not null
#
# Indexes
#
#  index_cards_on_activation_number              (activation_number) UNIQUE
#  index_cards_on_client_id_and_created_at       (client_id,created_at)
#  index_cards_on_client_id_and_idempotency_key  (client_id,idempotency_key) UNIQUE
#  index_cards_on_created_at                     (created_at)
#  index_cards_on_product_id_and_created_at      (product_id,created_at)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => users.id) ON DELETE => restrict
#  fk_rails_...  (product_id => products.id) ON DELETE => restrict
#
