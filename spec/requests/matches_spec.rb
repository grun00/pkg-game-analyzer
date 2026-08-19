require "rails_helper"

RSpec.describe "Api::V1::Matches", type: :request do
  let(:user)      { create(:user) }
  let(:other)     { create(:user) }
  let(:dashboard) { create(:dashboard, user: user) }
  let(:headers)   { auth_headers(user) }

  let(:valid_params) do
    {
      match: {
        opponent_deck: "dragapult",
        result:        "win",
        description:   "Great game",
        hand_quality:  4,
        played_at:     1.hour.ago.iso8601
      }
    }
  end

  let(:invalid_params) do
    { match: { opponent_deck: "", result: "", hand_quality: 0, played_at: "" } }
  end

  def json
    JSON.parse(response.body)
  end

  context "when not authenticated" do
    it "returns 401 for GET /api/v1/dashboards/:id/matches" do
      get api_v1_dashboard_matches_path(dashboard)
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 for POST /api/v1/dashboards/:id/matches" do
      post api_v1_dashboard_matches_path(dashboard), params: valid_params
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "when authenticated" do
    describe "GET /api/v1/dashboards/:id/matches" do
      it "returns http success" do
        get api_v1_dashboard_matches_path(dashboard), headers: headers
        expect(response).to have_http_status(:ok)
      end

      it "only returns matches belonging to the dashboard" do
        create(:match, dashboard: dashboard, opponent_deck: :dragapult)
        other_db = create(:dashboard, user: other)
        create(:match, dashboard: other_db, opponent_deck: :raging_bolt)

        get api_v1_dashboard_matches_path(dashboard), headers: headers

        decks = json.map { |m| m["opponent_deck"] }
        expect(decks).to include("dragapult")
        expect(decks).not_to include("raging_bolt")
      end

      it "returns 404 when accessing another user's dashboard" do
        other_db = create(:dashboard, user: other)
        get api_v1_dashboard_matches_path(other_db), headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end

    describe "POST /api/v1/dashboards/:id/matches" do
      it "creates a match scoped to the dashboard" do
        expect { post api_v1_dashboard_matches_path(dashboard), params: valid_params, headers: headers }
          .to change(Match, :count).by(1)
        expect(response).to have_http_status(:created)
        expect(Match.last.dashboard).to eq(dashboard)
        expect(json["opponent_deck"]).to eq("dragapult")
      end

      it "returns unprocessable_content on invalid data" do
        post api_v1_dashboard_matches_path(dashboard), params: invalid_params, headers: headers
        expect(response).to have_http_status(:unprocessable_content)
        expect(json["errors"]).to be_present
      end

      it "does not create a match on invalid data" do
        expect { post api_v1_dashboard_matches_path(dashboard), params: invalid_params, headers: headers }
          .not_to change(Match, :count)
      end

      it "cannot add a match to another user's dashboard" do
        other_db = create(:dashboard, user: other)
        post api_v1_dashboard_matches_path(other_db), params: valid_params, headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end

    describe "GET /api/v1/dashboards/:dashboard_id/matches/:id" do
      let(:match) { create(:match, dashboard: dashboard) }

      it "returns the match as JSON for own match" do
        get api_v1_dashboard_match_path(dashboard, match), headers: headers
        expect(response).to have_http_status(:ok)
        expect(json["id"]).to eq(match.id)
      end

      it "returns 404 when accessing a match from another user's dashboard" do
        other_db    = create(:dashboard, user: other)
        other_match = create(:match, dashboard: other_db)
        get api_v1_dashboard_match_path(other_db, other_match), headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end

    describe "PATCH /api/v1/dashboards/:dashboard_id/matches/:id" do
      let(:match) { create(:match, dashboard: dashboard, result: "loss") }

      it "updates the match" do
        patch api_v1_dashboard_match_path(dashboard, match), params: { match: { result: "win" } }, headers: headers
        expect(response).to have_http_status(:ok)
        expect(match.reload.result).to eq("win")
      end

      it "returns unprocessable_content on invalid data" do
        patch api_v1_dashboard_match_path(dashboard, match), params: { match: { hand_quality: 9 } }, headers: headers
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "cannot update a match from another user's dashboard" do
        other_db    = create(:dashboard, user: other)
        other_match = create(:match, dashboard: other_db, result: "loss")
        patch api_v1_dashboard_match_path(other_db, other_match), params: { match: { result: "win" } }, headers: headers
        expect(response).to have_http_status(:not_found)
        expect(other_match.reload.result).to eq("loss")
      end
    end

    describe "DELETE /api/v1/dashboards/:dashboard_id/matches/:id" do
      let!(:match) { create(:match, dashboard: dashboard) }

      it "destroys the match and returns no_content" do
        expect { delete api_v1_dashboard_match_path(dashboard, match), headers: headers }
          .to change(Match, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end

      it "cannot delete a match from another user's dashboard" do
        other_db    = create(:dashboard, user: other)
        other_match = create(:match, dashboard: other_db)
        expect { delete api_v1_dashboard_match_path(other_db, other_match), headers: headers }
          .not_to change(Match, :count)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
