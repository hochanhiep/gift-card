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
        end
      end

      response "401", "Rejects the login when the password is wrong" do
        let(:credentials) { { email: "test@example.com", password: "wrong-password" } }

        run_test!
      end

      response "401", "Rejects the login when no user has the email" do
        let(:credentials) { { email: "unknown@example.com", password: "Password123" } }

        run_test!
      end

      response "401", "Rejects the login when the user is deactivated" do
        let(:credentials) { { email: "test@example.com", password: "Password123" } }
        before { user.update!(active: false) }

        run_test!
      end
    end
  end
end
