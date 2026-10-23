module Reports
  class CardTotals < ApplicationService
    def initialize(cards, range)
      @cards = cards
      @range = range
    end

    def execute
      totals = @cards.created_within(@range).select(*Totals::COLUMNS).take

      Totals.summary(totals)
    end
  end
end
