class CardSerializer
  def initialize(card)
    @card = card
  end

  def as_json
    {
      id:                @card.id,
      product_id:        @card.product_id,
      activation_number: @card.activation_number,
      pin:               @card.pin,
      denomination:      @card.denomination,
      payout_rate:       @card.payout_rate,
      state:             @card.state,
      cancelled_at:      @card.cancelled_at,
      created_at:        @card.created_at
    }
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
