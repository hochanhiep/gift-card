module Reports
  module Totals
    ISSUED = Card.states[:issued]
    CANCELLED = Card.states[:cancelled]

    COLUMNS = [
      "COUNT(*) FILTER (WHERE cards.state = #{ISSUED}) AS issued_count",
      "COALESCE(SUM(cards.denomination) FILTER (WHERE cards.state = #{ISSUED}), 0) AS issued_amount",
      "COALESCE(ROUND(SUM(cards.denomination * cards.payout_rate / 100) FILTER (WHERE cards.state = #{ISSUED}), 2), 0) AS payout", # rubocop:disable Layout/LineLength
      "COUNT(*) FILTER (WHERE cards.state = #{CANCELLED}) AS cancelled_count",
      "COALESCE(SUM(cards.denomination) FILTER (WHERE cards.state = #{CANCELLED}), 0) AS cancelled_amount"
    ].freeze

    def self.summary(row)
      {
        spending: { cards: row.issued_count, amount: row.issued_amount, payout: row.payout },
        cancellations: { cards: row.cancelled_count, amount: row.cancelled_amount }
      }
    end
  end
end
