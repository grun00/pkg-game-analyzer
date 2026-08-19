require "rails_helper"

RSpec.describe "Api::V1::Sessions", type: :request do
  let(:user) { create(:user, password: "password123", password_confirmation: "password123") }

  def json
    JSON.parse(response.body)
  end

  describe "POST /api/v1/login" do
    it "authenticates with valid credentials and returns a JWT" do
      post user_session_path, params: {
        user: { email: user.email, password: "password123" }
      }, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.headers["Authorization"]).to match(/\ABearer .+/)
      expect(json.dig("user", "id")).to eq(user.id)
      expect(json.dig("user", "email")).to eq(user.email)
      expect(json.dig("user", "role")).to eq("regular")
    end

    it "rejects invalid credentials" do
      post user_session_path, params: {
        user: { email: user.email, password: "wrong-password" }
      }, as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(response.headers["Authorization"]).to be_nil
    end
  end

  describe "DELETE /api/v1/logout" do
    it "revokes the token so it can no longer be used" do
      post user_session_path, params: {
        user: { email: user.email, password: "password123" }
      }, as: :json
      token = response.headers["Authorization"]

      delete destroy_user_session_path, headers: { "Authorization" => token }
      expect(response).to have_http_status(:no_content)

      get api_v1_meta_path, headers: { "Authorization" => token }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
