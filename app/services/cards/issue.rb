module Cards
  class Issue < ApplicationService
    ACTIVATION_CHARS = [ *"A".."Z", *"0".."9" ].freeze

    def initialize(client:, product_id:, idempotency_key:)
      @client = client
      @product_id = product_id.to_i
      @idempotency_key = idempotency_key
    end

    def execute
      card = existing_card

      return replay(card) if card

      product = @client.products.find_by(id: @product_id)

      return Result.new(error: :product_not_found) unless product
      return Result.new(error: :product_unavailable) unless product.available?

      Result.new(card: create_card(product), replayed: false)
    rescue ActiveRecord::RecordNotUnique
      card = existing_card
      raise unless card

      replay(card)
    end

    private

    def existing_card
      @client.cards.find_by(idempotency_key: @idempotency_key)
    end

    def replay(card)
      return Result.new(error: :idempotency_key_reused) if card.product_id != @product_id

      Result.new(card: card, replayed: true)
    end

    def create_card(product)
      @client.cards.create!(
        product: product,
        idempotency_key: @idempotency_key,
        activation_number: activation_number,
        pin: pin_for(product),
        denomination: product.denomination,
        payout_rate: @client.payout_rate
      )
    end

    def activation_number
      SecureRandom.alphanumeric(16, chars: ACTIVATION_CHARS).scan(/.{4}/).join("-")
    end

    def pin_for(product)
      return unless product.pin_required?

      format("%06d", SecureRandom.random_number(1_000_000))
    end
  end
end
