module Admin
  class ClientsController < BaseController
    include Paginatable

    before_action :require_client, only: %i[show update state]

    def index
      clients, page_info = paginate(User.client.order(:email))

      render json: { data: clients.map { |client| ClientSerializer.new(client) } }.merge(page_info)
    end

    def show
      render json: { data: ClientSerializer.new(@client) }
    end

    def create
      client = User.client.create!(client_params)

      render json: { data: ClientSerializer.new(client) }, status: :created
    end

    def update
      @client.update!(client_params)

      render json: { data: ClientSerializer.new(@client) }
    end

    def state
      @client.update!(state: params.require(:state))

      render json: { data: ClientSerializer.new(@client) }
    end

    private

    def require_client
      @client = User.client.find_by(id: params[:id])

      render_error :not_found, code: :client_not_found unless @client
    end

    def client_params
      params.require(:client).permit(:email, :password, :payout_rate)
    end
  end
end
