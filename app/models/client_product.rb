class ClientProduct < ApplicationRecord
  belongs_to :client, class_name: "User"
  belongs_to :product

  validate :client_must_be_client

  private

  def client_must_be_client
    errors.add(:client, "must be a client") unless client&.client?
  end
end

# == Schema Information
#
# Table name: client_products
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :bigint           not null
#  product_id :bigint           not null
#
# Indexes
#
#  index_client_products_on_client_id_and_product_id  (client_id,product_id) UNIQUE
#  index_client_products_on_product_id                (product_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => users.id) ON DELETE => restrict
#  fk_rails_...  (product_id => products.id) ON DELETE => restrict
#
