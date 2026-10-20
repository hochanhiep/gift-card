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

# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  active          :boolean          default(TRUE), not null
#  email           :citext           not null
#  password_digest :string           not null
#  payout_rate     :decimal(5, 2)
#  role            :integer          default("client"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
