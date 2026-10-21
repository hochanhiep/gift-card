require "swagger_helper"

RSpec.describe "Admin brands", type: :request do
  let(:admin)         { create(:user, :admin) }
  let(:Authorization) { "Bearer #{JwtService.issue(admin).value}" }

  path "/admin/brands" do
    get "List brands" do
      tags "Brands"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :page,     in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false

      let(:page)          { nil }
      let(:per_page)      { nil }

      before do
        create(:brand, name: "Starbucks")
        create(:brand, name: "Highlands Coffee")
      end

      response "200", "Returns brands sorted by name" do
        run_test! do
          expect(json["data"].map { |brand| brand["name"] }).to eq([ "Highlands Coffee", "Starbucks" ])
          expect(json["data"].first.keys).to match_array(%w[id name state custom_fields created_at updated_at])
          expect(json.slice("page", "per_page", "total")).to eq("page" => 1, "per_page" => 20, "total" => 2)
        end
      end

      response "200", "Returns the second page when per_page is 1" do
        let(:page)     { 2 }
        let(:per_page) { 1 }

        run_test! do
          expect(json["data"].map { |brand| brand["name"] }).to eq([ "Starbucks" ])
          expect(json.slice("page", "per_page", "total")).to eq("page" => 2, "per_page" => 1, "total" => 2)
        end
      end

      auth_failures(wrong_role: :client)
    end

    post "Create a brand" do
      tags "Brands"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          brand: {
            type: :object,
            properties: {
              name: { type: :string },
              custom_fields: {
                type: :array,
                maxItems: 5,
                description: "Optional, up to 5 fields",
                items: {
                  type: :object,
                  properties: { label: { type: :string }, value: { type: :string } },
                  required: %w[label value]
                }
              }
            },
            required: %w[name]
          }
        },
        required: %w[brand]
      }

      let(:body) do
        { brand: { name: " Starbucks ", custom_fields: [ { label: "Country", value: "Vietnam" } ] } }
      end

      response "201", "Creates the brand and returns it" do
        run_test! do
          expect(json["data"]["name"]).to eq("Starbucks")
          expect(json["data"]["state"]).to eq("active")
          expect(json["data"]["custom_fields"]).to eq([ { "label" => "Country", "value" => "Vietnam" } ])
          expect(Brand.count).to eq(1)
        end
      end

      response "422", "Rejects the brand when the name is already taken" do
        before { create(:brand, name: "starbucks") }

        run_test! do
          expect(json["errors"].first).to include("code" => "invalid", "field" => "name")
          expect(Brand.count).to eq(1)
        end
      end

      response "400", "Rejects the request when the brand params are missing" do
        let(:body) { {} }

        run_test! do
          expect(json["errors"].first["code"]).to eq("parameter_missing")
        end
      end

      auth_failures(wrong_role: :client)
    end
  end

  path "/admin/brands/{id}" do
    parameter name: :id, in: :path, type: :integer

    get "Show a brand" do
      tags "Brands"
      produces "application/json"
      security [ bearerAuth: [] ]

      let(:brand)         { create(:brand, name: "Phuc Long") }
      let(:id)            { brand.id }

      response "200", "Returns the brand" do
        run_test! do
          expect(json["data"]["id"]).to eq(brand.id)
          expect(json["data"]["name"]).to eq("Phuc Long")
        end
      end

      response "404", "Responds with Brand not found when the id does not match any brand" do
        let(:id) { 0 }

        run_test! do
          expect(json["errors"].first["code"]).to eq("brand_not_found")
        end
      end

      auth_failures(wrong_role: :client)
    end

    patch "Update a brand" do
      tags "Brands"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          brand: {
            type: :object,
            properties: {
              name: { type: :string },
              custom_fields: {
                type: :array,
                maxItems: 5,
                description: "Replaces the current fields when sent",
                items: {
                  type: :object,
                  properties: { label: { type: :string }, value: { type: :string } },
                  required: %w[label value]
                }
              }
            }
          }
        },
        required: %w[brand]
      }

      let(:brand)         { create(:brand, name: "Phuc Long") }
      let(:id)            { brand.id }
      let(:body) do
        { brand: { name: " The Coffee House ", custom_fields: [ { label: "Country", value: "Vietnam" } ] } }
      end

      response "200", "Updates the brand and returns it" do
        run_test! do
          expect(json["data"]["name"]).to eq("The Coffee House")
          expect(json["data"]["custom_fields"]).to eq([ { "label" => "Country", "value" => "Vietnam" } ])
          expect(brand.reload.name).to eq("The Coffee House")
        end
      end

      response "422", "Rejects the update when another brand already has the name" do
        before { create(:brand, name: "the coffee house") }

        run_test! do
          expect(json["errors"].first).to include("code" => "invalid", "field" => "name")
          expect(brand.reload.name).to eq("Phuc Long")
        end
      end

      response "404", "Responds with Brand not found when the id does not match any brand" do
        let(:id) { 0 }

        run_test! do
          expect(json["errors"].first["code"]).to eq("brand_not_found")
        end
      end

      auth_failures(wrong_role: :client)
    end
  end

  path "/admin/brands/{id}/state" do
    parameter name: :id, in: :path, type: :integer

    patch "Change a brand's state" do
      tags "Brands"
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

      let(:brand)         { create(:brand, name: "Highlands Coffee") }
      let(:id)            { brand.id }
      let(:body)          { { state: "inactive" } }

      response "200", "Deactivates the brand and returns it" do
        run_test! do
          expect(json["data"]["state"]).to eq("inactive")
          expect(brand.reload).to be_inactive
        end
      end

      response "422", "Rejects the change when the state is not active or inactive" do
        let(:body) { { state: "archived" } }

        run_test! do
          expect(json["errors"].first).to include("code" => "invalid", "field" => "state")
          expect(brand.reload).to be_active
        end
      end

      response "400", "Rejects the request when the state is missing" do
        let(:body) { {} }

        run_test! do
          expect(json["errors"].first["code"]).to eq("parameter_missing")
        end
      end

      response "404", "Responds with Brand not found when the id does not match any brand" do
        let(:id) { 0 }

        run_test! do
          expect(json["errors"].first["code"]).to eq("brand_not_found")
        end
      end

      auth_failures(wrong_role: :client)
    end
  end
end
