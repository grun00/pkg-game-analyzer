require "rails_helper"

RSpec.describe "Api::V1::Profile", type: :request do
  let(:user) { create(:user) }

  def json
    JSON.parse(response.body)
  end

  describe "PATCH /api/v1/profile" do
    it "requires authentication" do
      patch api_v1_profile_path, params: { user: { role: "content_creator" } }, as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "lets a regular user opt into the content_creator role" do
      patch api_v1_profile_path,
            params: { user: { role: "content_creator" } },
            headers: auth_headers(user),
            as: :json

      expect(response).to have_http_status(:ok)
      expect(json.dig("user", "role")).to eq("content_creator")
      expect(user.reload.role_content_creator?).to be(true)
    end

    it "is reversible back to regular" do
      user.update!(role: :content_creator)

      patch api_v1_profile_path,
            params: { user: { role: "regular" } },
            headers: auth_headers(user),
            as: :json

      expect(response).to have_http_status(:ok)
      expect(json.dig("user", "role")).to eq("regular")
      expect(user.reload.role_regular?).to be(true)
    end

    it "rejects an unknown role" do
      patch api_v1_profile_path,
            params: { user: { role: "admin" } },
            headers: auth_headers(user),
            as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["errors"]).to be_present
      expect(user.reload.role_regular?).to be(true)
    end
  end
end
