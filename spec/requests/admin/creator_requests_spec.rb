require "rails_helper"

RSpec.describe "Api::V1::Admin::CreatorRequests", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:regular) { create(:user) }

  describe "GET /api/v1/admin/creator_requests" do
    it "forbids non-admins" do
      create(:creator_request)
      get "/api/v1/admin/creator_requests", headers: auth_headers(regular), as: :json
      expect(response).to have_http_status(:forbidden)
    end

    it "lists only pending requests for admins" do
      pending = create(:creator_request)
      create(:creator_request, :approved)

      get "/api/v1/admin/creator_requests", headers: auth_headers(admin), as: :json

      expect(response).to have_http_status(:ok)
      ids = JSON.parse(response.body).map { |r| r["id"] }
      expect(ids).to eq([pending.id])
    end
  end

  describe "PATCH /api/v1/admin/creator_requests/:id" do
    let(:applicant) { create(:user) }
    let!(:request_record) { create(:creator_request, user: applicant) }

    it "forbids non-admins" do
      patch "/api/v1/admin/creator_requests/#{request_record.id}",
            params: { creator_request: { status: "approved" } },
            headers: auth_headers(regular), as: :json
      expect(response).to have_http_status(:forbidden)
    end

    it "approves a request, promotes the user and emails them" do
      expect {
        patch "/api/v1/admin/creator_requests/#{request_record.id}",
              params: { creator_request: { status: "approved" } },
              headers: auth_headers(admin), as: :json
      }.to have_enqueued_mail(CreatorRequestMailer, :decision_email)

      expect(response).to have_http_status(:ok)
      expect(request_record.reload.status).to eq("approved")
      expect(applicant.reload.role_content_creator?).to be(true)
    end

    it "copies the proposed name and bio onto the promoted creator" do
      request_record.update!(proposed_name: "Ash", proposed_bio: "Pallet Town")

      patch "/api/v1/admin/creator_requests/#{request_record.id}",
            params: { creator_request: { status: "approved" } },
            headers: auth_headers(admin), as: :json

      applicant.reload
      expect(applicant.name).to eq("Ash")
      expect(applicant.bio).to eq("Pallet Town")
    end

    it "approves without demoting an admin applicant" do
      admin_applicant = create(:user, :admin)
      admin_request = create(:creator_request, user: admin_applicant)

      patch "/api/v1/admin/creator_requests/#{admin_request.id}",
            params: { creator_request: { status: "approved" } },
            headers: auth_headers(admin), as: :json

      expect(response).to have_http_status(:ok)
      expect(admin_request.reload.status).to eq("approved")
      expect(admin_applicant.reload.role_admin?).to be(true)
    end

    it "rejects a request without promoting the user" do
      patch "/api/v1/admin/creator_requests/#{request_record.id}",
            params: { creator_request: { status: "rejected" } },
            headers: auth_headers(admin), as: :json

      expect(response).to have_http_status(:ok)
      expect(request_record.reload.status).to eq("rejected")
      expect(applicant.reload.role_regular?).to be(true)
    end

    it "returns 422 for an invalid status" do
      patch "/api/v1/admin/creator_requests/#{request_record.id}",
            params: { creator_request: { status: "pending" } },
            headers: auth_headers(admin), as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
