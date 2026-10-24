module Client
  class ReportsController < BaseController
    include DateRangeable

    def spending
      report = Reports::CardTotals.execute(current_user.cards, date_range)

      render json: { data: report, from: params[:from], to: params[:to] }
    end
  end
end
