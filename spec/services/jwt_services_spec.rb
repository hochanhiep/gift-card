require "rails_helper"

RSpec.describe JwtService do
  let(:user) { create(:user, :client) }

  describe ".issue" do
    it "returns a token that decodes to the user" do
      token = described_class.issue(user)
      payload = described_class.decode(token.value)

      expect(payload["sub"]).to eq(user.id)
      expect(payload["role"]).to eq("client")
    end

    it "expires one hour after it is issued" do
      freeze_time do
        token = described_class.issue(user)

        expect(token.expires_at).to eq(1.hour.from_now)
        expect(described_class.decode(token.value)["exp"]).to eq(1.hour.from_now.to_i)
      end
    end
  end

  describe ".decode" do
    it "rejects an expired token" do
      token = described_class.issue(user)

      travel_to(2.hours.from_now) do
        expect { described_class.decode(token.value) }.to raise_error(JWT::ExpiredSignature)
      end
    end

    it "rejects a token signed with another secret" do
      forged = JWT.encode({ sub: user.id }, "wrong-secret", "HS256")

      expect { described_class.decode(forged) }.to raise_error(JWT::DecodeError)
    end

    it "rejects a token that is not a JWT" do
      expect { described_class.decode("garbage") }.to raise_error(JWT::DecodeError)
    end
  end

  describe ".revoke" do
    it "rejects the revoked token but not other tokens of the user" do
      token = described_class.issue(user)
      other = described_class.issue(user)

      described_class.revoke(described_class.decode(token.value))

      expect { described_class.decode(token.value) }.to raise_error(JWT::InvalidJtiError)
      expect(described_class.decode(other.value)["sub"]).to eq(user.id)
    end

    it "keeps the revoked entry only until the token expires" do
      payload = described_class.decode(described_class.issue(user).value)
      described_class.revoke(payload)

      travel_to(Time.zone.at(payload["exp"]) + 1.second) do
        expect(Rails.cache.exist?("revoked_token:#{payload["jti"]}")).to be(false)
      end
    end
  end
end
