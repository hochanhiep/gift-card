require "swagger_helper"

RSpec.describe "Client products", type: :request do
  let(:client)        { create(:user, :client) }
  let(:Authorization) { "Bearer #{JwtService.issue(client).value}" }

  let(:starbucks)     { create(:brand, name: "Starbucks") }
  let(:highlands)     { create(:brand, name: "Highlands Coffee") }
  let(:starbucks_100) { create(:product, brand: starbucks, name: "Starbucks 100K", denomination: 100_000) }
  let(:starbucks_200) { create(:product, brand: starbucks, name: "Starbucks 200K", denomination: 200_000) }
  let(:highlands_50)  { create(:product, brand: highlands, name: "Highlands 50K", denomination: 50_000) }

  before { client.update!(product_ids: [ starbucks_100.id, starbucks_200.id, highlands_50.id ]) }

  path "/client/products" do
    get "Browse the catalog" do
      tags "Catalog"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :q,                in: :query, type: :string, required: false
      parameter name: :search_in,        in: :query, required: false, schema: { type: :string, enum: %w[product brand] },
                                         description: "Search only product names or only brand names. Searches both by default"
      parameter name: :min_denomination, in: :query, type: :string, required: false
      parameter name: :max_denomination, in: :query, type: :string, required: false
      parameter name: :page,             in: :query, type: :integer, required: false
      parameter name: :per_page,         in: :query, type: :integer, required: false

      let(:q)                { nil }
      let(:search_in)        { nil }
      let(:min_denomination) { nil }
      let(:max_denomination) { nil }
      let(:page)             { nil }
      let(:per_page)         { nil }

      response "200", "Returns the client's available products sorted by name" do
        run_test! do
          expect(json["data"].map { |product| product["name"] }).to eq([ "Highlands 50K", "Starbucks 100K", "Starbucks 200K" ])
          expect(json["total"]).to eq(3)
        end
      end

      response "200", "Returns only matching products when filters are given" do
        let(:q)                { "starbucks" }
        let(:search_in)        { "brand" }
        let(:max_denomination) { "100000" }

        run_test! do
          expect(json["data"].map { |product| product["name"] }).to eq([ "Starbucks 100K" ])
        end
      end

      auth_failures(wrong_role: :admin)
    end
  end

  path "/client/products/{id}" do
    parameter name: :id, in: :path, type: :integer

    get "Show a catalog product" do
      tags "Catalog"
      produces "application/json"
      security [ bearerAuth: [] ]

      let(:id) { starbucks_100.id }

      response "200", "Returns the product" do
        run_test! do
          expect(json["data"]).to include("id" => starbucks_100.id, "name" => "Starbucks 100K")
        end
      end

      response "404", "Responds with Product not found when the product is not in the client's catalog" do
        let(:id) { create(:product, brand: starbucks, name: "Starbucks 500K").id }

        run_test! do
          expect(json["errors"].first["code"]).to eq("product_not_found")
        end
      end

      auth_failures(wrong_role: :admin)
    end
  end
end
