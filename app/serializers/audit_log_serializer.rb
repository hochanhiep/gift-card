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
