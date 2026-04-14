require "rails_helper"

RSpec.describe "Matches", type: :request do
  let(:user)      { create(:user) }
  let(:other)     { create(:user) }
  let(:dashboard) { create(:dashboard, user: user) }

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

  context "when not authenticated" do
    it "redirects GET /dashboards/:id/matches to sign in" do
      get dashboard_matches_path(dashboard)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects GET /dashboards/:id/matches/new to sign in" do
      get new_dashboard_match_path(dashboard)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects POST /dashboards/:id/matches to sign in" do
      post dashboard_matches_path(dashboard), params: valid_params
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "when authenticated" do
    before { sign_in user }

    describe "GET /dashboards/:id/matches" do
      it "returns http success" do
        get dashboard_matches_path(dashboard)
        expect(response).to have_http_status(:ok)
      end

      it "only shows matches belonging to the dashboard" do
        own         = create(:match, dashboard: dashboard, opponent_deck: :dragapult)
        other_db    = create(:dashboard, user: other)
        other_match = create(:match, dashboard: other_db, opponent_deck: :raging_bolt)
        get dashboard_matches_path(dashboard)
        expect(response.body).to include("Dragapult")
        expect(response.body).not_to include("Raging bolt")
      end

      it "redirects when accessing another user's dashboard" do
        other_db = create(:dashboard, user: other)
        get dashboard_matches_path(other_db)
        expect(response).to redirect_to(dashboards_path)
      end
    end

    describe "GET /dashboards/:id/matches/new" do
      it "returns http success" do
        get new_dashboard_match_path(dashboard)
        expect(response).to have_http_status(:ok)
      end
    end

    describe "POST /dashboards/:id/matches" do
      it "creates a match and redirects to the dashboard" do
        expect { post dashboard_matches_path(dashboard), params: valid_params }
          .to change(Match, :count).by(1)
        expect(response).to redirect_to(dashboard_path(dashboard))
      end

      it "scopes the new match to the dashboard" do
        post dashboard_matches_path(dashboard), params: valid_params
        expect(Match.last.dashboard).to eq(dashboard)
      end

      it "re-renders :new with unprocessable_content on invalid data" do
        post dashboard_matches_path(dashboard), params: invalid_params
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Register a Match")
      end

      it "does not create a match on invalid data" do
        expect { post dashboard_matches_path(dashboard), params: invalid_params }
          .not_to change(Match, :count)
      end

      it "cannot add a match to another user's dashboard" do
        other_db = create(:dashboard, user: other)
        post dashboard_matches_path(other_db), params: valid_params
        expect(response).to redirect_to(dashboards_path)
      end
    end

    describe "GET /dashboards/:dashboard_id/matches/:id/edit" do
      let(:match) { create(:match, dashboard: dashboard) }

      it "returns http success for own match" do
        get edit_dashboard_match_path(dashboard, match)
        expect(response).to have_http_status(:ok)
      end

      it "redirects when accessing a match from another user's dashboard" do
        other_db    = create(:dashboard, user: other)
        other_match = create(:match, dashboard: other_db)
        get edit_dashboard_match_path(other_db, other_match)
        expect(response).to redirect_to(dashboards_path)
      end
    end

    describe "PATCH /dashboards/:dashboard_id/matches/:id" do
      let(:match) { create(:match, dashboard: dashboard, result: "loss") }

      it "updates the match and redirects to the dashboard" do
        patch dashboard_match_path(dashboard, match), params: { match: { result: "win" } }
        expect(match.reload.result).to eq("win")
        expect(response).to redirect_to(dashboard_path(dashboard))
      end

      it "re-renders :edit with unprocessable_content on invalid data" do
        patch dashboard_match_path(dashboard, match), params: { match: { hand_quality: 9 } }
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "cannot update a match from another user's dashboard" do
        other_db    = create(:dashboard, user: other)
        other_match = create(:match, dashboard: other_db, result: "loss")
        patch dashboard_match_path(other_db, other_match), params: { match: { result: "win" } }
        expect(response).to redirect_to(dashboards_path)
        expect(other_match.reload.result).to eq("loss")
      end
    end

    describe "DELETE /dashboards/:dashboard_id/matches/:id" do
      let!(:match) { create(:match, dashboard: dashboard) }

      it "destroys the match and redirects to the matches list" do
        expect { delete dashboard_match_path(dashboard, match) }.to change(Match, :count).by(-1)
        expect(response).to redirect_to(dashboard_matches_path(dashboard))
      end

      it "cannot delete a match from another user's dashboard" do
        other_db    = create(:dashboard, user: other)
        other_match = create(:match, dashboard: other_db)
        expect { delete dashboard_match_path(other_db, other_match) }.not_to change(Match, :count)
      end
    end
  end
end
