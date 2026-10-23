module DateRangeable
  extend ActiveSupport::Concern

  included do
    rescue_from Date::Error, with: -> { render_error :unprocessable_content, code: :invalid_date }
  end

  private

  def date_range
    from = Date.iso8601(params[:from]).beginning_of_day if params[:from].present?
    to = Date.iso8601(params[:to]).end_of_day if params[:to].present?

    from..to if from || to
  end
end
