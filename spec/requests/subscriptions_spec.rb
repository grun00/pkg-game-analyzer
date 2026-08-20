require "rails_helper"

RSpec.describe "Api::V1::Subscriptions", type: :request do
  let(:user) { create(:user) }

  describe "GET /api/v1/subscriptions" do
    it "requires authentication" do
      get "/api/v1/subscriptions", as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns the current user's subscriptions newest first" do
      c1 = create(:user, :content_creator)
      c2 = create(:user, :content_creator)
      old = create(:subscription, subscriber: user, creator: c1, created_at: 2.days.ago)
      recent = create(:subscription, subscriber: user, creator: c2, created_at: 1.hour.ago)
      create(:subscription, subscriber: create(:user), creator: c1)

      get "/api/v1/subscriptions", headers: auth_headers(user), as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.map { |s| s["id"] }).to eq([recent.id, old.id])
      expect(body.first["creator"]["id"]).to eq(c2.id)
    end
  end
end
