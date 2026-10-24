module Admin
  class AuditLogsController < BaseController
    include Paginatable
    include DateRangeable

    def index
      logs, page_info = paginate(AuditLogs::Search.execute(params, date_range))

      render json: { data: logs.map { |log| AuditLogSerializer.new(log) } }.merge(page_info)
    end
  end
end
