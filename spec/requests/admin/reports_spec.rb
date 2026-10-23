require "swagger_helper"

RSpec.describe "Admin reports", type: :request do
  let(:admin)         { create(:user, :admin) }
  let(:Authorization) { "Bearer #{JwtService.issue(admin).value}" }

  let(:michael) { create(:user, :client, email: "michael@example.com", payout_rate: 10) }
  let(:dwight)  { create(:user, :client, email: "dwight@example.com", payout_rate: 5) }

  let(:starbucks_100) do
    create(:product, brand: create(:brand, name: "Starbucks"), name: "Starbucks 100K", denomination: 100_000)
  end
  let(:highlands_50) do
    create(:product, brand: create(:brand, name: "Highlands Coffee"), name: "Highlands 50K", denomination: 50_000)
  end

  path "/admin/reports" do
    get "Report card spending and cancellations by brand or by client" do
      tags "Reports"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :report_type, in: :query, type: :string, enum: %w[brand client], required: true,
                description: "Report totals by brand or by client"
      parameter name: :from, in: :query, type: :string, format: :date, required: false,
                description: "Date (YYYY-MM-DD)"
      parameter name: :to, in: :query, type: :string, format: :date, required: false,
                description: "Date (YYYY-MM-DD)"

      let(:report_type) { "brand" }
      let(:from)        { "2026-10-01" }
      let(:to)          { "2026-10-31" }

      before do
        october = Time.utc(2026, 10, 10)

        create(:card, client: michael, product: starbucks_100, created_at: october)
        create(:card, :cancelled, client: michael, product: highlands_50, created_at: october)
        create(:card, client: dwight, product: starbucks_100, created_at: october)
        create(:card, client: dwight, product: highlands_50, created_at: Time.utc(2026, 11, 2))
      end

      response "200", "Returns totals for each brand with cards issued in the range" do
        run_test! do
          expect(json["data"]).to eq([
            {
              "id" => highlands_50.brand_id, "name" => "Highlands Coffee",
              "spending" => { "cards" => 0, "amount" => "0.0", "payout" => "0.0" },
              "cancellations" => { "cards" => 1, "amount" => "50000.0" }
            },
            {
              "id" => starbucks_100.brand_id, "name" => "Starbucks",
              "spending" => { "cards" => 2, "amount" => "200000.0", "payout" => "15000.0" },
              "cancellations" => { "cards" => 0, "amount" => "0.0" }
            }
          ])
        end
      end

      response "200", "Returns totals for each client with cards issued in the range" do
        let(:report_type) { "client" }

        run_test! do
          expect(json["data"]).to eq([
            {
              "id" => dwight.id, "email" => "dwight@example.com",
              "spending" => { "cards" => 1, "amount" => "100000.0", "payout" => "5000.0" },
              "cancellations" => { "cards" => 0, "amount" => "0.0" }
            },
            {
              "id" => michael.id, "email" => "michael@example.com",
              "spending" => { "cards" => 1, "amount" => "100000.0", "payout" => "10000.0" },
              "cancellations" => { "cards" => 1, "amount" => "50000.0" }
            }
          ])
        end
      end

      response "422", "Rejects the request when report_type is not brand or client" do
        let(:report_type) { "product" }

        run_test! do
          expect(json["errors"].first["code"]).to eq("invalid_report_type")
        end
      end

      response "422", "Rejects the request when a date is not in YYYY-MM-DD format" do
        let(:to) { "31-10-2026" }

        run_test! do
          expect(json["errors"].first["code"]).to eq("invalid_date")
        end
      end

      auth_failures(wrong_role: :client)
    end
  end
end
