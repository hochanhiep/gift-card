module AuditLogs
  class Search < ApplicationService
    def initialize(filters, range)
      @filters = filters
      @range = range
    end

    def execute
      scope = AuditLog.all
      scope = scope.where(user_id: @filters[:user_id]) if @filters[:user_id].present?
      scope = scope.where(action: @filters[:log_action]) if @filters[:log_action].present?
      scope = scope.where(record_type: @filters[:record_type]) if @filters[:record_type].present?
      scope = scope.where(created_at: @range) if @range

      scope.order(created_at: :desc, id: :desc)
    end
  end
end
