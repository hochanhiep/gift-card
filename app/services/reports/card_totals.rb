module Reports
  class CardTotals < ApplicationService
    ISSUED = Card.states[:issued]
    CANCELLED = Card.states[:cancelled]

    def initialize(cards, range)
      @cards = cards
      @range = range
    end

    def execute
      cards = @range ? @cards.where(created_at: @range) : @cards

      totals = cards.select(
        "COUNT(*) FILTER (WHERE state = #{ISSUED}) AS issued_count",
        "COALESCE(SUM(denomination) FILTER (WHERE state = #{ISSUED}), 0) AS issued_amount",
        "COALESCE(ROUND(SUM(denomination * payout_rate / 100) FILTER (WHERE state = #{ISSUED}), 2), 0) AS payout",
        "COUNT(*) FILTER (WHERE state = #{CANCELLED}) AS cancelled_count",
        "COALESCE(SUM(denomination) FILTER (WHERE state = #{CANCELLED}), 0) AS cancelled_amount"
      ).take

      {
        spending: { cards: totals.issued_count, amount: totals.issued_amount, payout: totals.payout },
        cancellations: { cards: totals.cancelled_count, amount: totals.cancelled_amount }
      }
    end
  end
end
