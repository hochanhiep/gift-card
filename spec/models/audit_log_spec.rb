require "rails_helper"

RSpec.describe AuditLog do
  describe ".record" do
    let(:user) { create(:user, :admin) }

    before do
      Current.user = user
      Current.ip_address = "203.0.113.7"
      Current.user_agent = "curl/8.4.0"
    end

    it "records action" do
      brand = create(:brand)

      log = described_class.record(action: "brand.update", record: brand)

      expect(log).to have_attributes(
        action: "brand.update", user_id: user.id, record_type: "Brand", record_id: brand.id,
        user_agent: "curl/8.4.0"
      )
      expect(log.ip_address.to_s).to eq("203.0.113.7")
    end

    it "filters pins and passwords" do
      log = described_class.record(
        action: "user.update",
        change_set: { password_digest: %w[old new], email: %w[a@example.com b@example.com] },
        metadata: { pin: "123456", card: { pin: "654321" }, password: "Password123" }
      )

      expect(log.change_set).to eq(
        "password_digest" => "[FILTERED]", "email" => %w[a@example.com b@example.com]
      )
      expect(log.metadata).to eq(
        "pin" => "[FILTERED]", "card" => { "pin" => "[FILTERED]" }, "password" => "[FILTERED]"
      )
    end
  end

  it "cannot be changed once saved" do
    log = described_class.record(action: AuditLog::LOGIN)

    expect { log.update!(action: "123") }.to raise_error(ActiveRecord::ReadOnlyRecord)
    expect { log.destroy! }.to raise_error(ActiveRecord::ReadOnlyRecord)
  end
end
