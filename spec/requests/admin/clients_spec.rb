require "swagger_helper"

RSpec.describe "Admin clients", type: :request do
  let(:admin)         { create(:user, :admin) }
  let(:Authorization) { "Bearer #{JwtService.issue(admin).value}" }

  path "/admin/clients" do
    get "List clients" do
      tags "Clients"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :page,     in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false

      let(:page)     { nil }
      let(:per_page) { nil }

      before do
        create(:user, :client, email: "zoe@example.com")
        create(:user, :client, email: "anna@example.com")
      end

      response "200", "Returns clients sorted by email without admins" do
        run_test! do
          expect(json["data"].map { |client| client["email"] }).to eq(%w[anna@example.com zoe@example.com])
          expect(json["data"].first.keys).to match_array(%w[id email payout_rate state created_at updated_at])
          expect(json["total"]).to eq(2)
        end
      end

      auth_failures(wrong_role: :client)
    end

    post "Create a client" do
      tags "Clients"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          client: {
            type: :object,
            properties: {
              email: { type: :string },
              password: { type: :string, minLength: 8 },
              payout_rate: { type: :string, example: "10.00", description: "0 to 100" }
            },
            required: %w[email password payout_rate]
          }
        },
        required: %w[client]
      }

      let(:body) do
        { client: { email: " Shop@Example.com ", password: "Password123", payout_rate: "12.5", role: "admin" } }
      end

      response "201", "Creates the client and returns it without the password" do
        run_test! do
          expect(json["data"]).to include("email" => "shop@example.com", "payout_rate" => "12.5", "state" => "active")
          expect(json["data"].keys).not_to include("password", "password_digest")
          expect(User.find(json["data"]["id"])).to be_client
        end
      end

      response "422", "Rejects the client when the payout rate is above 100" do
        let(:body) { { client: { email: "shop@example.com", password: "Password123", payout_rate: "150" } } }

        run_test! do
          expect(json["errors"].first).to include("code" => "invalid", "field" => "payout_rate")
          expect(User.client.count).to eq(0)
        end
      end

      response "400", "Rejects the request when the client params are missing" do
        let(:body) { {} }

        run_test! do
          expect(json["errors"].first["code"]).to eq("parameter_missing")
        end
      end

      auth_failures(wrong_role: :client)
    end
  end

  path "/admin/clients/{id}" do
    parameter name: :id, in: :path, type: :integer

    get "Show a client" do
      tags "Clients"
      produces "application/json"
      security [ bearerAuth: [] ]

      let(:client) { create(:user, :client, email: "shop@example.com") }
      let(:id)     { client.id }

      response "200", "Returns the client" do
        run_test! do
          expect(json["data"]).to include("id" => client.id, "email" => "shop@example.com")
        end
      end

      response "404", "Responds with Client not found when the id belongs to an admin" do
        let(:id) { admin.id }

        run_test! do
          expect(json["errors"].first["code"]).to eq("client_not_found")
        end
      end

      auth_failures(wrong_role: :client)
    end

    patch "Update a client" do
      tags "Clients"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          client: {
            type: :object,
            properties: {
              email: { type: :string },
              password: { type: :string, minLength: 8 },
              payout_rate: { type: :string, example: "10.00", description: "0 to 100" }
            }
          }
        },
        required: %w[client]
      }

      let(:client) { create(:user, :client, email: "shop@example.com", payout_rate: 10) }
      let(:id)     { client.id }
      let(:body)   { { client: { payout_rate: "20" } } }

      response "200", "Updates the client and returns it" do
        run_test! do
          expect(json["data"]["payout_rate"]).to eq("20.0")
          expect(client.reload.payout_rate).to eq(20)
        end
      end

      response "422", "Rejects the update when the payout rate is negative" do
        let(:body) { { client: { payout_rate: "-1" } } }

        run_test! do
          expect(json["errors"].first).to include("code" => "invalid", "field" => "payout_rate")
          expect(client.reload.payout_rate).to eq(10)
        end
      end

      response "404", "Responds with Client not found when the id does not match any client" do
        let(:id) { 0 }

        run_test! do
          expect(json["errors"].first["code"]).to eq("client_not_found")
        end
      end

      auth_failures(wrong_role: :client)
    end
  end

  path "/admin/clients/{id}/state" do
    parameter name: :id, in: :path, type: :integer

    patch "Change a client's state" do
      tags "Clients"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          state: { type: :string, enum: %w[active inactive] }
        },
        required: %w[state]
      }

      let(:client) { create(:user, :client, email: "shop@example.com") }
      let(:id)     { client.id }
      let(:body)   { { state: "inactive" } }

      response "200", "Deactivates the client and returns it" do
        run_test! do
          expect(json["data"]["state"]).to eq("inactive")
          expect(client.reload).to be_inactive
        end
      end

      response "422", "Rejects the change when the state is not active or inactive" do
        let(:body) { { state: "archived" } }

        run_test! do
          expect(json["errors"].first).to include("code" => "invalid", "field" => "state")
          expect(client.reload).to be_active
        end
      end

      response "400", "Rejects the request when the state is missing" do
        let(:body) { {} }

        run_test! do
          expect(json["errors"].first["code"]).to eq("parameter_missing")
        end
      end

      response "404", "Responds with Client not found when the id belongs to an admin" do
        let(:id) { admin.id }

        run_test! do
          expect(json["errors"].first["code"]).to eq("client_not_found")
        end
      end

      auth_failures(wrong_role: :client)
    end
  end
end
