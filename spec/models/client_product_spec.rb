require "rails_helper"

RSpec.describe ClientProduct do
  it "is valid for a client" do
    expect(build(:client_product)).to be_valid
  end

  it "does not allow an admin" do
    client_product = build(:client_product, client: create(:user, :admin))

    expect(client_product).not_to be_valid
    expect(client_product.errors[:client]).to include("must be a client")
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
