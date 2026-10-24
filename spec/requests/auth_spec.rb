require "swagger_helper"

RSpec.describe "Auth", type: :request do
  path "/auth/login" do
    post "Log in and get a token" do
      tags "Auth"
      consumes "application/json"
      produces "application/json"

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email:    { type: :string },
          password: { type: :string }
        },
        required: %w[email password]
      }

      let!(:user) { create(:user, :client, email: "test@example.com", password: "Password123") }

      response "200", "Returns a token and the user when the email and password are correct" do
        let(:credentials) { { email: "test@Example.com ", password: "Password123" } }

        run_test! do
          data = json["data"]

          expect(JwtService.decode(data["token"])["sub"]).to eq(user.id)
          expect(data["user"]["email"]).to eq("test@example.com")
          expect(AuditLog.last).to have_attributes(action: AuditLog::LOGIN, user_id: user.id)
        end
      end

      response "401", "Rejects the login when the password is wrong" do
        let(:credentials) { { email: "test@example.com", password: "wrong-password" } }

        run_test! do
          log = AuditLog.last

          expect(log).to have_attributes(action: AuditLog::LOGIN_FAILED, user_id: nil)
          expect(log.metadata).to eq("email" => "test@example.com", "reason" => "invalid_credentials")
          expect(log.attributes.to_s).not_to include("wrong-password")
        end
      end

      response "401", "Rejects the login when the email is not in the system" do
        let(:credentials) { { email: "unknown@example.com", password: "Password123" } }

        run_test! do
          expect(AuditLog.last).to have_attributes(action: AuditLog::LOGIN_FAILED, user_id: nil)
        end
      end

      response "401", "Rejects the login when the user is deactivated" do
        let(:credentials) { { email: "test@example.com", password: "Password123" } }
        before { user.update!(state: :inactive) }

        run_test! do
          expect(AuditLog.last).to have_attributes(action: AuditLog::LOGIN_FAILED, user_id: user.id)
          expect(AuditLog.last.metadata["reason"]).to eq("inactive")
        end
      end
    end
  end
end
