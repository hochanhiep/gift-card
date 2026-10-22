# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.find_or_create_by!(email: ENV.fetch("ADMIN_EMAIL", "admin@example.com")) do |u|
  u.password = ENV.fetch("ADMIN_PASSWORD", "ChangeMe12345")
  u.role     = :admin
end

if Rails.env.development?
  brands = {
    "Starbucks"        => { state: :active,   custom_fields: [ { "label" => "Country", "value" => "USA" } ] },
    "Highlands Coffee" => { state: :active,   custom_fields: [ { "label" => "Country", "value" => "Vietnam" } ] },
    "Phuc Long"        => { state: :active,   custom_fields: [] },
    "The Coffee House" => { state: :inactive, custom_fields: [] },
    "KFC"              => { state: :active,   custom_fields: [ { "label" => "Category", "value" => "Fast food" } ] },
    "McDonald's"       => { state: :active,   custom_fields: [ { "label" => "Category", "value" => "Fast food" } ] },
    "Lotteria"         => { state: :active,   custom_fields: [ { "label" => "Category", "value" => "Fast food" } ] },
    "Jollibee"         => { state: :inactive, custom_fields: [ { "label" => "Category", "value" => "Fast food" } ] }
  }.to_h do |name, attrs|
    [ name, Brand.find_or_create_by!(name: name) { |b| b.assign_attributes(attrs) } ]
  end

  products = [
    [ "Starbucks",        "Starbucks 100K",        100_000, :active ],
    [ "Starbucks",        "Starbucks 200K",        200_000, :active ],
    [ "Starbucks",        "Starbucks 500K",        500_000, :inactive ],
    [ "Highlands Coffee", "Highlands 50K",         50_000,  :active ],
    [ "Highlands Coffee", "Highlands 100K",        100_000, :active ],
    [ "Phuc Long",        "Phuc Long 50K",         50_000,  :active ],
    [ "Phuc Long",        "Phuc Long 100K",        100_000, :active ],
    [ "The Coffee House", "The Coffee House 100K", 100_000, :active ],
    [ "KFC",              "KFC 100K",              100_000, :active ],
    [ "KFC",              "KFC 200K",              200_000, :active ],
    [ "McDonald's",       "McDonald's 50K",        50_000,  :active ],
    [ "McDonald's",       "McDonald's 100K",       100_000, :inactive ],
    [ "Lotteria",         "Lotteria 50K",          50_000,  :active ],
    [ "Lotteria",         "Lotteria 150K",         150_000, :active ],
    [ "Jollibee",         "Jollibee 100K",         100_000, :active ]
  ].to_h do |brand, name, denomination, state|
    product = brands[brand].products.find_or_create_by!(name: name) do |p|
      p.denomination  = denomination
      p.state         = state
      p.custom_fields = [ { "label" => "Valid for", "value" => "12 months" } ]
    end

    [ name, product ]
  end

  clients = {
    "shop.saigon@example.com" => {
      payout_rate: 10, state: :active,
      products: [ "Starbucks 100K", "Starbucks 200K", "Starbucks 500K", "Highlands 50K", "The Coffee House 100K",
                  "KFC 100K", "KFC 200K", "McDonald's 50K", "McDonald's 100K" ]
    },
    "shop.hanoi@example.com" => {
      payout_rate: 7.5, state: :active,
      products: [ "Phuc Long 50K", "Phuc Long 100K", "Highlands 100K",
                  "Lotteria 50K", "Lotteria 150K", "Jollibee 100K", "KFC 100K" ]
    },
    "shop.closed@example.com" => {
      payout_rate: 5, state: :inactive,
      products: [ "Starbucks 100K" ]
    }
  }

  clients.each do |email, attrs|
    client = User.client.find_or_create_by!(email: email) do |u|
      u.password    = "Password123"
      u.payout_rate = attrs[:payout_rate]
      u.state       = attrs[:state]
    end

    client.update!(product_ids: products.values_at(*attrs[:products]).map(&:id))
  end
end
