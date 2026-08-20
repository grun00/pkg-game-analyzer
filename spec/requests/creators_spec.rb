require "rails_helper"

RSpec.describe "Api::V1::Creators", type: :request do
  let(:user) { create(:user) }
  let(:creator) { create(:user, :content_creator) }

  describe "GET /api/v1/creators" do
    it "requires authentication" do
      get "/api/v1/creators", as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "lists only content creators with a subscribed flag" do
      creator
      create(:user)

      get "/api/v1/creators", headers: auth_headers(user), as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.map { |c| c["id"] }).to eq([creator.id])
      expect(body.first["subscribed"]).to be(false)
    end

    it "exposes name and bio but never the creator's email" do
      creator.update!(name: "Ash Ketchum", bio: "Gotta catch 'em all")

      get "/api/v1/creators", headers: auth_headers(user), as: :json

      row = JSON.parse(response.body).first
      expect(row["name"]).to eq("Ash Ketchum")
      expect(row["bio"]).to eq("Gotta catch 'em all")
      expect(row).not_to have_key("email")
    end

    it "falls back to Creator #<id> when the creator has no name" do
      creator.update!(name: nil)

      get "/api/v1/creators", headers: auth_headers(user), as: :json

      expect(JSON.parse(response.body).first["name"]).to eq("Creator ##{creator.id}")
    end

    it "marks creators the user follows as subscribed" do
      create(:subscription, subscriber: user, creator: creator)

      get "/api/v1/creators", headers: auth_headers(user), as: :json

      expect(JSON.parse(response.body).first["subscribed"]).to be(true)
    end
  end

  describe "GET /api/v1/creators/:id" do
    it "returns the creator" do
      get "/api/v1/creators/#{creator.id}", headers: auth_headers(user), as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["id"]).to eq(creator.id)
    end

    it "404s for a non-creator id" do
      other = create(:user)
      get "/api/v1/creators/#{other.id}", headers: auth_headers(user), as: :json
      expect(response).to have_http_status(:not_found)
    end

    it "includes the creator's published content but not their drafts" do
      published = create(:content, creator: creator, status: :published)
      create(:content, :draft, creator: creator)

      get "/api/v1/creators/#{creator.id}", headers: auth_headers(user), as: :json

      ids = JSON.parse(response.body)["contents"].map { |c| c["id"] }
      expect(ids).to eq([published.id])
    end

    it "returns an empty content list when the creator has none" do
      get "/api/v1/creators/#{creator.id}", headers: auth_headers(user), as: :json
      expect(JSON.parse(response.body)["contents"]).to eq([])
    end
  end

  describe "POST /api/v1/creators/:id/subscribe" do
    it "creates a subscription" do
      expect {
        post "/api/v1/creators/#{creator.id}/subscribe",
             headers: auth_headers(user), as: :json
      }.to change(Subscription, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["subscribed"]).to be(true)
    end

    it "rejects subscribing to yourself" do
      post "/api/v1/creators/#{creator.id}/subscribe",
           headers: auth_headers(creator), as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a duplicate subscription" do
      create(:subscription, subscriber: user, creator: creator)
      post "/api/v1/creators/#{creator.id}/subscribe",
           headers: auth_headers(user), as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /api/v1/creators/:id/subscribe" do
    it "removes the subscription" do
      create(:subscription, subscriber: user, creator: creator)

      expect {
        delete "/api/v1/creators/#{creator.id}/subscribe",
               headers: auth_headers(user), as: :json
      }.to change(Subscription, :count).by(-1)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["subscribed"]).to be(false)
    end

    it "is a no-op when not subscribed" do
      delete "/api/v1/creators/#{creator.id}/subscribe",
             headers: auth_headers(user), as: :json
      expect(response).to have_http_status(:ok)
    end
  end
end
