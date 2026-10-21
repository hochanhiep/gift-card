require "swagger_helper"

RSpec.describe "Admin client products", type: :request do
  let(:admin)         { create(:user, :admin) }
  let(:Authorization) { "Bearer #{JwtService.issue(admin).value}" }

  let(:client)      { create(:user, :client, email: "shop@example.com") }
  let(:client_id)   { client.id }
  let(:starbucks)   { create(:brand, name: "Starbucks") }
  let(:starbucks_1) { create(:product, brand: starbucks, name: "Starbucks 100K", denomination: 100_000) }
  let(:starbucks_2) { create(:product, brand: starbucks, name: "Starbucks 200K", denomination: 200_000) }
  let(:highlands)   { create(:product, brand: create(:brand, name: "Highlands Coffee"), name: "Highlands 50K", denomination: 50_000) }

  path "/admin/clients/{client_id}/products" do
    parameter name: :client_id, in: :path, type: :integer

    get "List the products a client can use" do
      tags "Clients"
      produces "application/json"
      security [ bearerAuth: [] ]

      before do
        create(:client_product, client: client, product: starbucks_2)
        create(:client_product, client: client, product: highlands)
        create(:client_product, product: starbucks_1)
      end

      response "200", "Returns only this client's products sorted by name" do
        run_test! do
          expect(json["data"].map { |product| product["name"] }).to eq([ "Highlands 50K", "Starbucks 200K" ])
        end
      end

      response "404", "Responds with Client not found when the id belongs to an admin" do
        let(:client_id) { admin.id }

        run_test! do
          expect(json["errors"].first["code"]).to eq("client_not_found")
        end
      end

      auth_failures(wrong_role: :client)
    end

    put "Replace the products a client can use" do
      tags "Clients"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          product_ids: { type: :array, items: { type: :integer }, description: "Send [] to remove all access" }
        },
        required: %w[product_ids]
      }

      let(:body) { { product_ids: [ starbucks_2.id, highlands.id ] } }

      before { create(:client_product, client: client, product: starbucks_1) }

      response "200", "Replaces the client's products with the given ones and returns them" do
        run_test! do
          expect(json["data"].map { |product| product["name"] }).to eq([ "Highlands 50K", "Starbucks 200K" ])
          expect(client.products).to contain_exactly(starbucks_2, highlands)
        end
      end

      response "200", "Ignores repeated product ids" do
        let(:body) { { product_ids: [ highlands.id, highlands.id ] } }

        run_test! do
          expect(client.products).to contain_exactly(highlands)
        end
      end

      response "200", "Removes all access when product_ids is empty" do
        let(:body) { { product_ids: [] } }

        run_test! do
          expect(json["data"]).to eq([])
          expect(client.products).to be_empty
        end
      end

      response "422", "Rejects the change and keeps the current products when an id does not match any product" do
        let(:body) { { product_ids: [ highlands.id, 0 ] } }

        run_test! do
          expect(json["errors"].first["code"]).to eq("unknown_product")
          expect(client.products).to contain_exactly(starbucks_1)
        end
      end

      response "400", "Rejects the request when product_ids is missing" do
        let(:body) { {} }

        run_test! do
          expect(json["errors"].first["code"]).to eq("parameter_missing")
        end
      end

      response "404", "Responds with Client not found when the id does not match any client" do
        let(:client_id) { 0 }

        run_test! do
          expect(json["errors"].first["code"]).to eq("client_not_found")
        end
      end

      auth_failures(wrong_role: :client)
    end
  end
end
