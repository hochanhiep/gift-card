class Card < ApplicationRecord
  belongs_to :client, class_name: "User"
  belongs_to :product

  enum :state, { issued: 0, cancelled: 1 }, default: :issued, validate: true

  validates :idempotency_key, length: { maximum: 255 }
  validate :cannot_be_reissued, on: :update

  encrypts :pin

  attr_readonly :client_id, :product_id, :idempotency_key, :activation_number, :pin, :denomination, :payout_rate

  private

  def cannot_be_reissued
    errors.add(:state, "cannot change back to issued") if state_changed?(from: "cancelled", to: "issued")
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
