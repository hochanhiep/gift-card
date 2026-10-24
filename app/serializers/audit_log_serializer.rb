class AuditLogSerializer
  def initialize(log)
    @log = log
  end

  def as_json
    {
      id:          @log.id,
      user_id:     @log.user_id,
      action:      @log.action,
      record_type: @log.record_type,
      record_id:   @log.record_id,
      change_set:  @log.change_set,
      metadata:    @log.metadata,
      ip_address:  @log.ip_address&.to_s,
      user_agent:  @log.user_agent,
      created_at:  @log.created_at
    }
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
