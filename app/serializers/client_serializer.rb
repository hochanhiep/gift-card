class ClientSerializer
  def initialize(client)
    @client = client
  end

  def as_json
    {
      id:          @client.id,
      email:       @client.email,
      payout_rate: @client.payout_rate,
      state:       @client.state,
      created_at:  @client.created_at,
      updated_at:  @client.updated_at
    }
  end
end
