require "rails_helper"

RSpec.describe "Api::V1::Registrations", type: :request do
  def json
    JSON.parse(response.body)
  end

  describe "POST /api/v1/signup" do
    it "creates a user with valid params" do
      expect {
        post user_registration_path, params: {
          user: {
            email: "new-trainer@pokemon.test",
            password: "password123",
            password_confirmation: "password123"
          }
        }, as: :json
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json.dig("user", "email")).to eq("new-trainer@pokemon.test")
    end

    it "returns errors when password confirmation does not match" do
      expect {
        post user_registration_path, params: {
          user: {
            email: "bad-trainer@pokemon.test",
            password: "password123",
            password_confirmation: "mismatch"
          }
        }, as: :json
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["errors"]).to be_present
    end

    it "returns errors when the email is already taken" do
      create(:user, email: "taken@pokemon.test")

      expect {
        post user_registration_path, params: {
          user: {
            email: "taken@pokemon.test",
            password: "password123",
            password_confirmation: "password123"
          }
        }, as: :json
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["errors"]).to be_present
    end
  end
end
