require "rails_helper"

RSpec.describe Auditable do
  let(:admin) { create(:user, :admin) }

  before { Current.user = admin }

  it "logs a create with every column" do
    brand = create(:brand, name: "Starbucks")

    expect(AuditLog.last).to have_attributes(
      action: "brand.create", user_id: admin.id, record_type: "Brand", record_id: brand.id
    )
    expect(AuditLog.last.change_set).to include("name" => [ nil, "Starbucks" ], "state" => [ nil, "active" ])
    expect(AuditLog.last.change_set).not_to include("id", "created_at", "updated_at")
  end

  it "logs only the changed columns on update" do
    brand = create(:brand, name: "Starbucks")
    brand.update!(name: "Starbucks VN")

    expect(AuditLog.last).to have_attributes(
      action: "brand.update", change_set: { "name" => [ "Starbucks", "Starbucks VN" ] }
    )
  end

  it "skips an update that changes nothing" do
    brand = create(:brand)

    expect { brand.update!(name: brand.name) }.not_to change(AuditLog, :count)
  end

  it "logs a destroy with the old values" do
    product = create(:product, name: "Starbucks 100K")
    product.destroy!

    expect(AuditLog.last).to have_attributes(action: "product.destroy", record_id: product.id)
    expect(AuditLog.last.change_set).to include("name" => [ "Starbucks 100K", nil ])
  end
end
