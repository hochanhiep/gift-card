class AuditLog < ApplicationRecord
  LOGIN = "auth.login".freeze
  LOGIN_FAILED = "auth.login_failed".freeze
  LOGOUT = "auth.logout".freeze
  CLIENT_PRODUCTS_UPDATE = "client_products.update".freeze
  CARD_ISSUE = "card.issue".freeze
  CARD_ISSUE_REFUSED = "card.issue_refused".freeze
  CARD_CANCEL = "card.cancel".freeze
  CARD_CANCEL_REFUSED = "card.cancel_refused".freeze

  FILTER = ActiveSupport::ParameterFilter.new([ /\Apin\z/i, /password/i, /digest/i ])

  validates :action, presence: true

  def self.record(action:, user: Current.user, record: nil, change_set: {}, metadata: {})
    create!(
      action: action,
      user_id: user&.id,
      record_type: record&.class&.name,
      record_id: record&.id,
      change_set: FILTER.filter(change_set),
      metadata: FILTER.filter(metadata),
      ip_address: Current.ip_address,
      user_agent: Current.user_agent
    )
  end

  def readonly?
    persisted?
  end
end

# == Schema Information
#
# Table name: audit_logs
#
#  id          :bigint           not null, primary key
#  action      :string           not null
#  change_set  :jsonb            not null
#  ip_address  :inet
#  metadata    :jsonb            not null
#  record_type :string
#  user_agent  :string
#  created_at  :datetime         not null
#  record_id   :bigint
#  user_id     :bigint
#
# Indexes
#
#  index_audit_logs_on_action_and_created_at      (action,created_at)
#  index_audit_logs_on_created_at                 (created_at)
#  index_audit_logs_on_record_type_and_record_id  (record_type,record_id)
#  index_audit_logs_on_user_id_and_created_at     (user_id,created_at)
#
