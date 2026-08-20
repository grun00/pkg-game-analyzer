require "rails_helper"

RSpec.describe "Api::V1::Profiles", type: :request do
  let(:creator) { create(:user, :content_creator) }

  describe "PATCH /api/v1/profile" do
    it "requires authentication" do
      patch "/api/v1/profile", params: { profile: { name: "X" } }, as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "forbids non-creators" do
      patch "/api/v1/profile",
            params: { profile: { name: "X" } },
            headers: auth_headers(create(:user)), as: :json
      expect(response).to have_http_status(:forbidden)
    end

    it "updates the creator's name and bio" do
      patch "/api/v1/profile",
            params: { profile: { name: "Ash Ketchum", bio: "Pallet Town" } },
            headers: auth_headers(creator), as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Ash Ketchum")
      expect(body["bio"]).to eq("Pallet Town")
      expect(creator.reload.name).to eq("Ash Ketchum")
    end

    it "rejects a bio longer than 200 characters" do
      patch "/api/v1/profile",
            params: { profile: { bio: "a" * 201 } },
            headers: auth_headers(creator), as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
