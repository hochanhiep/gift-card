require "swagger_helper"

RSpec.describe "Admin products", type: :request do
  let(:admin)         { create(:user, :admin) }
  let(:Authorization) { "Bearer #{JwtService.issue(admin).value}" }

  path "/admin/brands/{brand_id}/products" do
    parameter name: :brand_id, in: :path, type: :integer

    get "List a brand's products" do
      tags "Products"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :page,     in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false

      let(:brand)         { create(:brand, name: "Starbucks") }
      let(:brand_id)      { brand.id }
      let(:page)          { nil }
      let(:per_page)      { nil }

      before do
        create(:product, brand: brand, name: "Starbucks 200K", denomination: 200_000)
        create(:product, brand: brand, name: "Starbucks 100K", denomination: 100_000)
        create(:product, brand: create(:brand, name: "Highlands Coffee"), name: "Highlands 100K")
      end

      response "200", "Returns only this brand's products sorted by name" do
        run_test! do
          expect(json["data"].map { |product| product["name"] }).to eq([ "Starbucks 100K", "Starbucks 200K" ])
          expect(json["data"].first.keys).to match_array(
            %w[id brand_id brand_name name denomination pin_required state custom_fields created_at updated_at]
          )
          expect(json["total"]).to eq(2)
        end
      end

      response "404", "Responds with Brand not found when the brand id does not match any brand" do
        let(:brand_id) { 0 }

        run_test! do
          expect(json["errors"].first["code"]).to eq("brand_not_found")
        end
      end

      auth_failures(wrong_role: :client)
    end

    post "Create a product under a brand" do
      tags "Products"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          product: {
            type: :object,
            properties: {
              name: { type: :string },
              denomination: { type: :string, example: "100000.00" },
              pin_required: { type: :boolean, description: "Defaults to true" },
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
            required: %w[name denomination]
          }
        },
        required: %w[product]
      }

      let(:brand)         { create(:brand, name: "Starbucks") }
      let(:brand_id)      { brand.id }
      let(:body) do
        {
          product: {
            name: " Starbucks 100K ",
            denomination: "100000",
            custom_fields: [ { label: "Size", value: "Tall" } ]
          }
        }
      end

      response "201", "Creates the product under the brand and returns it" do
        run_test! do
          expect(json["data"]["brand_id"]).to eq(brand.id)
          expect(json["data"]["name"]).to eq("Starbucks 100K")
          expect(json["data"]["denomination"]).to eq("100000.0")
          expect(json["data"]["custom_fields"]).to eq([ { "label" => "Size", "value" => "Tall" } ])
          expect(brand.products.count).to eq(1)
        end
      end

      response "422", "Rejects the product when the denomination is not positive" do
        let(:body) { { product: { name: "Starbucks 0K", denomination: "0" } } }

        run_test! do
          expect(json["errors"].first).to include("code" => "invalid", "field" => "denomination")
          expect(Product.count).to eq(0)
        end
      end

      response "404", "Responds with Brand not found when the brand id does not match any brand" do
        let(:brand_id) { 0 }

        run_test! do
          expect(json["errors"].first["code"]).to eq("brand_not_found")
        end
      end

      auth_failures(wrong_role: :client)
    end
  end

  path "/admin/products/{id}" do
    parameter name: :id, in: :path, type: :integer

    get "Show a product" do
      tags "Products"
      produces "application/json"
      security [ bearerAuth: [] ]

      let(:product)       { create(:product, name: "Phuc Long 50K", denomination: 50_000) }
      let(:id)            { product.id }

      response "200", "Returns the product" do
        run_test! do
          expect(json["data"]["id"]).to eq(product.id)
          expect(json["data"]["name"]).to eq("Phuc Long 50K")
        end
      end

      response "404", "Responds with Product not found when the id does not match any product" do
        let(:id) { 0 }

        run_test! do
          expect(json["errors"].first["code"]).to eq("product_not_found")
        end
      end

      auth_failures(wrong_role: :client)
    end

    patch "Update a product" do
      tags "Products"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          product: {
            type: :object,
            properties: {
              name: { type: :string },
              denomination: { type: :string, example: "100000.00" },
              pin_required: { type: :boolean, description: "Defaults to true" },
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
        required: %w[product]
      }

      let(:brand)         { create(:brand, name: "The Coffee House") }
      let(:product)       { create(:product, brand: brand, name: "The Coffee House 50K", denomination: 50_000) }
      let(:id)            { product.id }
      let(:body)          { { product: { name: "The Coffee House 200K", denomination: "200000" } } }

      response "200", "Updates the product and returns it" do
        run_test! do
          expect(json["data"]["name"]).to eq("The Coffee House 200K")
          expect(json["data"]["denomination"]).to eq("200000.0")
          expect(product.reload.name).to eq("The Coffee House 200K")
        end
      end

      response "422", "Rejects the update when the brand already has a product with the name" do
        before { create(:product, brand: brand, name: "the coffee house 200k") }

        run_test! do
          expect(json["errors"].first).to include("code" => "invalid", "field" => "name")
          expect(product.reload.name).to eq("The Coffee House 50K")
        end
      end

      response "404", "Responds with Product not found when the id does not match any product" do
        let(:id) { 0 }

        run_test! do
          expect(json["errors"].first["code"]).to eq("product_not_found")
        end
      end

      auth_failures(wrong_role: :client)
    end

    delete "Delete a product" do
      tags "Products"
      produces "application/json"
      security [ bearerAuth: [] ]

      let!(:product)      { create(:product) }
      let(:id)            { product.id }

      response "204", "Deletes the product and removes it from the clients that could use it" do
        let(:client)        { create(:user, :client) }
        let(:other_product) { create(:product) }

        before do
          create(:client_product, client: client, product: product)
          create(:client_product, client: client, product: other_product)
        end

        run_test! do
          expect(Product.exists?(product.id)).to be(false)
          expect(client.products).to contain_exactly(other_product)
        end
      end

      response "409", "Rejects the delete when cards were already issued for the product" do
        let(:client) { create(:user, :client) }

        before do
          create(:client_product, client: client, product: product)
          create(:card, client: client, product: product)
        end

        run_test! do
          expect(json["errors"].first["code"]).to eq("product_has_cards")
          expect(Product.exists?(product.id)).to be(true)
          expect(client.products).to include(product)
        end
      end

      response "404", "Responds with Product not found when the id does not match any product" do
        let(:id) { 0 }

        run_test! do
          expect(json["errors"].first["code"]).to eq("product_not_found")
        end
      end

      auth_failures(wrong_role: :client)
    end
  end

  path "/admin/products/{id}/state" do
    parameter name: :id, in: :path, type: :integer

    patch "Change a product's state" do
      tags "Products"
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

      let(:product)       { create(:product, :inactive, name: "Starbucks 100K") }
      let(:id)            { product.id }
      let(:body)          { { state: "active" } }

      response "200", "Activates the product and returns it" do
        run_test! do
          expect(json["data"]["state"]).to eq("active")
          expect(product.reload).to be_active
        end
      end

      response "422", "Rejects the change when the state is not active or inactive" do
        let(:body) { { state: "archived" } }

        run_test! do
          expect(json["errors"].first).to include("code" => "invalid", "field" => "state")
          expect(product.reload).to be_inactive
        end
      end

      response "400", "Rejects the request when the state is missing" do
        let(:body) { {} }

        run_test! do
          expect(json["errors"].first["code"]).to eq("parameter_missing")
        end
      end

      response "404", "Responds with Product not found when the id does not match any product" do
        let(:id) { 0 }

        run_test! do
          expect(json["errors"].first["code"]).to eq("product_not_found")
        end
      end

      auth_failures(wrong_role: :client)
    end
  end
end
