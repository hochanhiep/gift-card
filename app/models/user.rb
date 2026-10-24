class User < ApplicationRecord
  include Auditable

  has_secure_password

  has_many :client_products, foreign_key: :client_id, inverse_of: :client
  has_many :products, through: :client_products
  has_many :cards, foreign_key: :client_id, inverse_of: :client

  enum :role, { admin: 0, client: 1 }
  enum :state, { active: 0, inactive: 1 }, default: :active, validate: true

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true,
                    uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true
  validates :payout_rate, presence: true,
                          numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
                          if: :client?
end

# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  email           :citext           not null
#  password_digest :string           not null
#  payout_rate     :decimal(5, 2)
#  role            :integer          default("client"), not null
#  state           :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
