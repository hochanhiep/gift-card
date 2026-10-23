module Client
  class ReportsController < BaseController
    include DateRangeable

    def spending
      report = Reports::CardTotals.execute(current_user.cards, date_range)

      render json: { data: { from: params[:from], to: params[:to] }.merge(report) }
    end
  end
end
