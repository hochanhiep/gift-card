module Reports
  class ByClient < ApplicationService
    def initialize(range, filters)
      @range = range
      @filters = filters
    end

    def execute
      clients = User.client.joins(:cards).merge(Card.created_within(@range))
                    .group(:id).order(:email)
                    .select(:id, :email, *Totals::COLUMNS)
      clients = clients.where(id: @filters[:client_id]) if @filters[:client_id].present?

      clients.map { |client| { id: client.id, email: client.email }.merge(Totals.summary(client)) }
    end
  end
end
