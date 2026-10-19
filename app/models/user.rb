class User < ApplicationRecord
  has_secure_password

  enum :role, { admin: 0, client: 1 }

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true,
                    uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true
  validates :payout_rate, presence: true,
                          numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
                          if: :client?
end
