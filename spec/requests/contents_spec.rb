require "rails_helper"

RSpec.describe "Api::V1::Contents", type: :request do
  let(:user)    { create(:user) }
  let(:creator) { create(:user, :content_creator) }

  describe "GET /api/v1/contents" do
    it "requires authentication" do
      get "/api/v1/contents", as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "lists published content from followed creators plus the user's own" do
      create(:subscription, subscriber: user, creator: creator)
      followed = create(:content, creator: creator, status: :published)
      draft_followed = create(:content, :draft, creator: creator)
      other_creator = create(:user, :content_creator)
      create(:content, creator: other_creator, status: :published)

      get "/api/v1/contents", headers: auth_headers(user), as: :json

      expect(response).to have_http_status(:ok)
      ids = JSON.parse(response.body).map { |c| c["id"] }
      expect(ids).to include(followed.id)
      expect(ids).not_to include(draft_followed.id)
    end

    it "includes the owner's own drafts" do
      own_draft = create(:content, :draft, creator: creator)

      get "/api/v1/contents", headers: auth_headers(creator), as: :json

      ids = JSON.parse(response.body).map { |c| c["id"] }
      expect(ids).to include(own_draft.id)
    end
  end

  describe "GET /api/v1/contents/:id" do
    it "returns published content to a subscriber" do
      create(:subscription, subscriber: user, creator: creator)
      content = create(:content, creator: creator, status: :published)

      get "/api/v1/contents/#{content.id}", headers: auth_headers(user), as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["id"]).to eq(content.id)
    end

    it "forbids a non-subscriber from viewing published content" do
      content = create(:content, creator: creator, status: :published)

      get "/api/v1/contents/#{content.id}", headers: auth_headers(user), as: :json

      expect(response).to have_http_status(:forbidden)
    end

    it "lets the owner view their own draft" do
      content = create(:content, :draft, creator: creator)

      get "/api/v1/contents/#{content.id}", headers: auth_headers(creator), as: :json

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/v1/contents" do
    let(:params) { { content: { title: "T", body: "B", content_type: "guide", status: "published" } } }

    it "lets a creator create content" do
      expect {
        post "/api/v1/contents", params: params, headers: auth_headers(creator), as: :json
      }.to change(Content, :count).by(1)
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["game_type"]).to eq("pokemon")
    end

    it "round-trips a non-default game_type" do
      post "/api/v1/contents",
           params: { content: params[:content].merge(game_type: "riftbound") },
           headers: auth_headers(creator), as: :json
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["game_type"]).to eq("riftbound")
      expect(Content.last.game_type).to eq("riftbound")
    end

    it "forbids a regular user from creating content" do
      post "/api/v1/contents", params: params, headers: auth_headers(user), as: :json
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /api/v1/contents/:id" do
    it "lets the owner update" do
      content = create(:content, creator: creator)
      patch "/api/v1/contents/#{content.id}",
            params: { content: { title: "Updated" } },
            headers: auth_headers(creator), as: :json
      expect(response).to have_http_status(:ok)
      expect(content.reload.title).to eq("Updated")
    end

    it "forbids a non-owner creator from updating" do
      other = create(:user, :content_creator)
      content = create(:content, creator: creator)
      patch "/api/v1/contents/#{content.id}",
            params: { content: { title: "Nope" } },
            headers: auth_headers(other), as: :json
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "DELETE /api/v1/contents/:id" do
    it "lets the owner delete" do
      content = create(:content, creator: creator)
      expect {
        delete "/api/v1/contents/#{content.id}", headers: auth_headers(creator), as: :json
      }.to change(Content, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end
