require "rails_helper"

RSpec.describe "Api::V1::Ratings", type: :request do
  let(:user)    { create(:user) }
  let(:creator) { create(:user, :content_creator) }
  let(:content) { create(:content, creator: creator, status: :published) }

  before { create(:subscription, subscriber: user, creator: creator) }

  describe "POST /api/v1/contents/:id/rating" do
    it "creates the current user's rating" do
      expect {
        post "/api/v1/contents/#{content.id}/rating",
             params: { rating: { stars: 4 } },
             headers: auth_headers(user), as: :json
      }.to change(Rating, :count).by(1)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["my_rating"]).to eq(4)
      expect(body["ratings_count"]).to eq(1)
    end

    it "upserts an existing rating instead of duplicating" do
      create(:rating, content: content, user: user, stars: 2)

      expect {
        post "/api/v1/contents/#{content.id}/rating",
             params: { rating: { stars: 5 } },
             headers: auth_headers(user), as: :json
      }.not_to change(Rating, :count)

      expect(JSON.parse(response.body)["my_rating"]).to eq(5)
    end

    it "rejects out-of-range stars" do
      post "/api/v1/contents/#{content.id}/rating",
           params: { rating: { stars: 6 } },
           headers: auth_headers(user), as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "forbids rating content from a creator the user does not follow" do
      other_creator = create(:user, :content_creator)
      other_content = create(:content, creator: other_creator, status: :published)

      post "/api/v1/contents/#{other_content.id}/rating",
           params: { rating: { stars: 3 } },
           headers: auth_headers(user), as: :json
      expect(response).to have_http_status(:forbidden)
    end

    it "requires authentication" do
      post "/api/v1/contents/#{content.id}/rating",
           params: { rating: { stars: 3 } }, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /api/v1/contents/:id/rating" do
    it "removes the current user's rating" do
      create(:rating, content: content, user: user, stars: 3)

      expect {
        delete "/api/v1/contents/#{content.id}/rating",
               headers: auth_headers(user), as: :json
      }.to change(Rating, :count).by(-1)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["my_rating"]).to be_nil
    end

    it "is a no-op when there is no rating" do
      delete "/api/v1/contents/#{content.id}/rating",
             headers: auth_headers(user), as: :json
      expect(response).to have_http_status(:ok)
    end
  end
end
