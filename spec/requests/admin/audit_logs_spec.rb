require "swagger_helper"

RSpec.describe "Admin audit logs", type: :request do
  let(:admin)         { create(:user, :admin) }
  let(:Authorization) { "Bearer #{JwtService.issue(admin).value}" }
  let(:dwight)        { create(:user, :client, email: "dwight@example.com") }

  path "/admin/audit_logs" do
    get "List the audit log" do
      tags "Audit logs"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :user_id,     in: :query, type: :integer, required: false
      parameter name: :log_action,  in: :query, type: :string,  required: false,
                description: "Action name, e.g. card.issue or brand.update"
      parameter name: :record_type, in: :query, type: :string,  required: false,
                description: "Model name, e.g. Brand, Product, User or Card"
      parameter name: :from,        in: :query, type: :string,  format: :date, required: false,
                description: "Date (YYYY-MM-DD)"
      parameter name: :to,          in: :query, type: :string,  format: :date, required: false,
                description: "Date (YYYY-MM-DD)"
      parameter name: :page,        in: :query, type: :integer, required: false
      parameter name: :per_page,    in: :query, type: :integer, required: false

      let!(:login) do
        create(:audit_log, action: AuditLog::LOGIN, user_id: dwight.id, created_at: Time.utc(2026, 10, 10))
      end
      let!(:issue) do
        create(:audit_log, action: AuditLog::CARD_ISSUE, user_id: dwight.id, record_type: "Card", record_id: 1,
                           metadata: { product_id: 5 }, created_at: Time.utc(2026, 10, 11))
      end
      let!(:brand_update) do
        create(:audit_log, action: "brand.update", user_id: admin.id, record_type: "Brand", record_id: 1,
                           change_set: { name: %w[Starbucks Highlands] }, created_at: Time.utc(2026, 9, 1))
      end

      response "200", "Returns the log newest first, one page at a time" do
        let(:per_page) { 2 }

        run_test! do
          newest = AuditLog.order(created_at: :desc, id: :desc).limit(2).pluck(:id)

          expect(json["data"].pluck("id")).to eq(newest)
          expect(json).to include("page" => 1, "per_page" => 2, "total" => AuditLog.count)
        end
      end

      response "200", "Returns only the entries matching the user, action and record type" do
        let(:user_id)     { dwight.id }
        let(:log_action)  { AuditLog::CARD_ISSUE }
        let(:record_type) { "Card" }

        run_test! do
          expect(json["data"].sole).to include(
            "id" => issue.id, "action" => "card.issue", "user_id" => dwight.id,
            "record_type" => "Card", "record_id" => 1, "metadata" => { "product_id" => 5 }
          )
        end
      end

      response "200", "Returns only the entries created in the date range" do
        let(:from) { "2026-09-01" }
        let(:to)   { "2026-10-10" }

        run_test! do
          expect(json["data"].pluck("id")).to eq([ login.id, brand_update.id ])
        end
      end

      response "422", "Rejects the request when a date is not in YYYY-MM-DD format" do
        let(:from) { "2026-09-31" }

        run_test! do
          expect(json["errors"].first["code"]).to eq("invalid_date")
        end
      end

      auth_failures(wrong_role: :client)
    end
  end
end
