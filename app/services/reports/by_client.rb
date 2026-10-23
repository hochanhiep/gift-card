module Reports
  class ByClient < ApplicationService
    def initialize(range)
      @range = range
    end

    def execute
      clients = User.client.joins(:cards).merge(Card.created_within(@range))
                    .group(:id).order(:email)
                    .select(:id, :email, *Totals::COLUMNS)

      clients.map { |client| { id: client.id, email: client.email }.merge(Totals.summary(client)) }
    end
  end
end
