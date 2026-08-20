require "rails_helper"

RSpec.describe "Api::V1::CreatorRequests", type: :request do
  let(:user) { create(:user) }

  describe "GET /api/v1/creator_requests" do
    it "requires authentication" do
      get "/api/v1/creator_requests", as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns the current user's requests newest first" do
      old = create(:creator_request, :rejected, user: user, created_at: 2.days.ago)
      recent = create(:creator_request, user: user, created_at: 1.hour.ago)
      create(:creator_request, user: create(:user))

      get "/api/v1/creator_requests", headers: auth_headers(user), as: :json

      expect(response).to have_http_status(:ok)
      ids = JSON.parse(response.body).map { |r| r["id"] }
      expect(ids).to eq([recent.id, old.id])
    end
  end

  describe "POST /api/v1/creator_requests" do
    it "creates a pending request and enqueues the submission email" do
      expect {
        post "/api/v1/creator_requests",
             params: { creator_request: { message: "Let me in" } },
             headers: auth_headers(user), as: :json
      }.to change(CreatorRequest, :count).by(1)
        .and have_enqueued_mail(CreatorRequestMailer, :submission_email)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["status"]).to eq("pending")
      expect(body["user"]["id"]).to eq(user.id)
    end

    it "rejects a second pending request with 422" do
      create(:creator_request, user: user)

      expect {
        post "/api/v1/creator_requests",
             params: { creator_request: { message: "again" } },
             headers: auth_headers(user), as: :json
      }.not_to change(CreatorRequest, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)["errors"]).to be_present
    end
  end
end
