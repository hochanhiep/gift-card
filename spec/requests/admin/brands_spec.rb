require "swagger_helper"

RSpec.describe "Admin brands", type: :request do
  path "/admin/brands" do
    get "List brands" do
      tags "Brands"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :page,     in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false

      let(:admin)         { create(:user, :admin) }
      let(:Authorization) { "Bearer #{JwtService.issue(admin).value}" }
      let(:page)          { nil }
      let(:per_page)      { nil }

      before do
        create(:brand, name: "Starbucks")
        create(:brand, name: "Highlands Coffee")
      end

      response "200", "Returns brands sorted by name" do
        run_test! do |response|
          expect(json["data"].map { |brand| brand["name"] }).to eq([ "Highlands Coffee", "Starbucks" ])
          expect(json["data"].first.keys).to match_array(%w[id name state custom_fields created_at updated_at])
          expect(json.slice("page", "per_page", "total")).to eq("page" => 1, "per_page" => 20, "total" => 2)
        end
      end

      response "200", "Returns the second page when per_page is 1" do
        let(:page)     { 2 }
        let(:per_page) { 1 }

        run_test! do |response|
          expect(json["data"].map { |brand| brand["name"] }).to eq([ "Starbucks" ])
          expect(json.slice("page", "per_page", "total")).to eq("page" => 2, "per_page" => 1, "total" => 2)
        end
      end

      response "401", "Rejects the request when the token is missing" do
        let(:Authorization) { nil }

        run_test!
      end

      response "403", "Rejects the request when the token belongs to a client" do
        let(:Authorization) { "Bearer #{JwtService.issue(create(:user, :client)).value}" }

        run_test!
      end
    end
  end
end
