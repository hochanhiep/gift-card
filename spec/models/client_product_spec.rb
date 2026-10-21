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
