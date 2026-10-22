module AuthFailures
  def auth_failures(wrong_role:)
    response "401", "Rejects the request when the token is missing" do
      let(:Authorization) { nil }

      run_test!
    end

    article = wrong_role == :admin ? "an" : "a"

    response "403", "Rejects the request when the token belongs to #{article} #{wrong_role}" do
      let(:Authorization) { "Bearer #{JwtService.issue(create(:user, wrong_role)).value}" }

      run_test!
    end
  end
end

RSpec.configure { |config| config.extend AuthFailures, type: :request }
