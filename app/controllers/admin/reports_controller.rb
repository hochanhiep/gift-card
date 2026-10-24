module Admin
  class ReportsController < BaseController
    include DateRangeable

    REPORTS = { "brand" => Reports::ByBrand, "client" => Reports::ByClient }.freeze

    def index
      report = REPORTS[params.require(:report_type)]

      return render_error :unprocessable_content, code: :invalid_report_type unless report

      render json: { data: report.execute(date_range, params), from: params[:from], to: params[:to] }
    end
  end
end
