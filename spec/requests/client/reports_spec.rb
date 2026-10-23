require "swagger_helper"

RSpec.describe "Client reports", type: :request do
  let(:client)        { create(:user, :client) }
  let(:Authorization) { "Bearer #{JwtService.issue(client).value}" }

  let(:starbucks)     { create(:brand, name: "Starbucks") }
  let(:starbucks_100) { create(:product, brand: starbucks, name: "Starbucks 100K", denomination: 100_000) }

  path "/client/reports/spending" do
    get "Report my spending and cancellations" do
      tags "Reports"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :from, in: :query, type: :string, format: :date, required: false,
                description: "Date (YYYY-MM-DD)"
      parameter name: :to, in: :query, type: :string, format: :date, required: false,
                description: "Date (YYYY-MM-DD)"

      let(:from) { "2026-10-01" }
      let(:to)   { "2026-10-31" }

      before do
        october = Time.utc(2026, 10, 10)

        create(:card, client: client, product: starbucks_100, payout_rate: 10, created_at: october)
        create(:card, :cancelled, client: client, product: starbucks_100, created_at: october)
        create(:card, client: client, product: starbucks_100, created_at: Time.utc(2026, 11, 2))
        create(:card, product: starbucks_100, created_at: october)
      end

      response "200", "Returns the client's spending and cancellations for cards issued in the range" do
        run_test! do
          expect(json["data"]).to include(
            "spending" => { "cards" => 1, "amount" => "100000.0", "payout" => "10000.0" },
            "cancellations" => { "cards" => 1, "amount" => "100000.0" }
          )
        end
      end

      response "422", "Rejects the request when a date is not in YYYY-MM-DD format" do
        let(:from) { "2026-13-01" }

        run_test! do
          expect(json["errors"].first["code"]).to eq("invalid_date")
        end
      end

      auth_failures(wrong_role: :admin)
    end
  end
end
