require "swagger_helper"

RSpec.describe "Client cards", type: :request do
  let(:client)        { create(:user, :client, payout_rate: 10) }
  let(:Authorization) { "Bearer #{JwtService.issue(client).value}" }

  let(:starbucks)     { create(:brand, name: "Starbucks") }
  let(:starbucks_100) { create(:product, brand: starbucks, name: "Starbucks 100K", denomination: 100_000) }
  let(:starbucks_200) { create(:product, brand: starbucks, name: "Starbucks 200K", denomination: 200_000) }

  before { client.update!(product_ids: [ starbucks_100.id, starbucks_200.id ]) }

  path "/client/cards" do
    post "Issue a card" do
      tags "Cards"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: "Idempotency-Key", in: :header, type: :string, required: true,
                description: "Unique per card request. Sending it again returns the same card"
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: { product_id: { type: :integer } },
        required: %w[product_id]
      }

      let(:"Idempotency-Key") { "order-1" }
      let(:body)              { { product_id: starbucks_100.id } }

      response "201", "Issues a new card for the product" do
        run_test! do
          expect(json["data"]).to include(
            "product_id" => starbucks_100.id, "denomination" => "100000.0",
            "payout_rate" => "10.0", "state" => "issued"
          )
          expect(json["data"]["pin"]).to be_present
          expect(response.headers["Idempotent-Replayed"]).to be_nil
          expect(AuditLog.last).to have_attributes(
            action: AuditLog::CARD_ISSUE, user_id: client.id, record_id: json["data"]["id"]
          )
        end
      end

      response "200", "Returns the same card when the request is sent again with the same key" do
        header "Idempotent-Replayed", schema: { type: :string }, description: "true when the card was issued before"

        let!(:card) { create(:card, client: client, product: starbucks_100, idempotency_key: "order-1") }

        run_test! do
          expect(json["data"]["id"]).to eq(card.id)
          expect(response.headers["Idempotent-Replayed"]).to eq("true")
          expect(Card.count).to eq(1)
        end
      end

      response "422", "Rejects the request when the key was already used for another product" do
        before { create(:card, client: client, product: starbucks_200, idempotency_key: "order-1") }

        run_test! do
          expect(json["errors"].first["code"]).to eq("idempotency_key_reused")
        end
      end

      response "422", "Rejects the request when the product or its brand is inactive" do
        before { starbucks_100.inactive! }

        run_test! do
          expect(json["errors"].first["code"]).to eq("product_unavailable")
          expect(Card.count).to eq(0)
          expect(AuditLog.last).to have_attributes(action: AuditLog::CARD_ISSUE_REFUSED, user_id: client.id)
          expect(AuditLog.last.metadata).to include("error" => "product_unavailable", "product_id" => starbucks_100.id)
        end
      end

      response "404", "Responds with Product not found when the client has no access to the product" do
        let(:body) { { product_id: create(:product).id } }

        run_test! do
          expect(json["errors"].first["code"]).to eq("product_not_found")
        end
      end

      response "400", "Rejects the request when the Idempotency-Key header is missing" do
        let(:"Idempotency-Key") { nil }

        run_test! do
          expect(json["errors"].first["code"]).to eq("idempotency_key_missing")
        end
      end

      response "422", "Rejects the request when the Idempotency-Key is longer than 255 characters" do
        let(:"Idempotency-Key") { "c" * 256 }

        run_test! do
          expect(json["errors"].first).to include("code" => "invalid", "field" => "idempotency_key")
        end
      end

      auth_failures(wrong_role: :admin)
    end
  end

  path "/client/cards/{id}/cancel" do
    parameter name: :id, in: :path, type: :integer

    post "Cancel a card" do
      tags "Cards"
      produces "application/json"
      security [ bearerAuth: [] ]

      let(:card) { create(:card, client: client, product: starbucks_100) }
      let(:id)   { card.id }

      response "200", "Cancels the card and returns it" do
        run_test! do
          expect(json["data"]["state"]).to eq("cancelled")
          expect(json["data"]["cancelled_at"]).to be_present
          expect(card.reload).to be_cancelled
          expect(AuditLog.last).to have_attributes(action: AuditLog::CARD_CANCEL, record_id: card.id)
        end
      end

      response "409", "Rejects the request when the card is already cancelled" do
        let(:card) { create(:card, :cancelled, client: client, product: starbucks_100) }

        run_test! do
          expect(json["errors"].first["code"]).to eq("already_cancelled")
          expect(AuditLog.last).to have_attributes(action: AuditLog::CARD_CANCEL_REFUSED, record_id: nil)
          expect(AuditLog.last.metadata).to include("error" => "already_cancelled")
        end
      end

      response "404", "Responds with Card not found when the card belongs to another client" do
        let(:id) { create(:card, product: starbucks_100).id }

        run_test! do
          expect(json["errors"].first["code"]).to eq("card_not_found")
        end
      end

      auth_failures(wrong_role: :admin)
    end
  end
end
