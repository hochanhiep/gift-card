module Cards
  class Cancel < ApplicationService
    def initialize(client:, card_id:)
      @client = client
      @card_id = card_id
    end

    def execute
      card = @client.cards.find_by(id: @card_id)

      return Result.new(error: :card_not_found) unless card
      return Result.new(error: :already_cancelled) if card.cancelled?

      card.update!(state: :cancelled, cancelled_at: Time.current)

      Result.new(card: card)
    end
  end
end
