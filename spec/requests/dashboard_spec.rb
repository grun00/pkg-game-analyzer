require "rails_helper"

RSpec.describe "Api::V1::Dashboards", type: :request do
  let(:user)    { create(:user) }
  let(:other)   { create(:user) }
  let(:headers) { auth_headers(user) }

  def json
    JSON.parse(response.body)
  end

  context "when not authenticated" do
    it "returns 401 for GET /api/v1/dashboards" do
      get api_v1_dashboards_path
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 for GET /api/v1/dashboards/:id/export" do
      dashboard = create(:dashboard)
      get export_api_v1_dashboard_path(dashboard)
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "when authenticated" do
    describe "GET /api/v1/dashboards (index)" do
      it "returns http success" do
        get api_v1_dashboards_path, headers: headers
        expect(response).to have_http_status(:ok)
      end

      it "lists only the current user's dashboards with summary stats" do
        own = create(:dashboard, user: user, name: "My Deck Tracker")
        create(:match, :win,  dashboard: own)
        create(:match, :loss, dashboard: own)
        create(:dashboard, user: other, name: "Rival Tracker")

        get api_v1_dashboards_path, headers: headers

        names = json.map { |d| d["name"] }
        expect(names).to include("My Deck Tracker")
        expect(names).not_to include("Rival Tracker")

        summary = json.find { |d| d["id"] == own.id }
        expect(summary["matches_count"]).to eq(2)
        expect(summary["wins_count"]).to eq(1)
        expect(summary["win_rate"]).to eq(50.0)
      end
    end

    describe "POST /api/v1/dashboards" do
      it "creates a dashboard scoped to the current user" do
        expect { post api_v1_dashboards_path, params: { dashboard: { name: "Regionals" } }, headers: headers }
          .to change(Dashboard, :count).by(1)
        expect(response).to have_http_status(:created)
        expect(json["name"]).to eq("Regionals")
        expect(Dashboard.last.user).to eq(user)
      end

      it "returns unprocessable_content when name is blank" do
        expect { post api_v1_dashboards_path, params: { dashboard: { name: "" } }, headers: headers }
          .not_to change(Dashboard, :count)
        expect(response).to have_http_status(:unprocessable_content)
        expect(json["errors"]).to be_present
      end
    end

    describe "GET /api/v1/dashboards/:id (show)" do
      let(:dashboard) { create(:dashboard, user: user) }

      it "returns the dashboard as JSON" do
        get api_v1_dashboard_path(dashboard), headers: headers
        expect(response).to have_http_status(:ok)
        expect(json["id"]).to eq(dashboard.id)
        expect(json["name"]).to eq(dashboard.name)
      end

      it "returns 404 when accessing another user's dashboard" do
        other_db = create(:dashboard, user: other)
        get api_v1_dashboard_path(other_db), headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end

    describe "GET /api/v1/dashboards/:id/stats" do
      let(:dashboard) { create(:dashboard, user: user) }

      it "returns aggregated stats with serialized recent matches" do
        create(:match, :win,  dashboard: dashboard)
        create(:match, :loss, dashboard: dashboard)

        get stats_api_v1_dashboard_path(dashboard), headers: headers

        expect(response).to have_http_status(:ok)
        expect(json["total"]).to eq(2)
        expect(json["wins"]).to eq(1)
        expect(json["recent_matches"].size).to eq(2)
        expect(json["recent_matches"].first).to include("opponent_deck", "result")
      end

      it "returns 404 for another user's dashboard" do
        other_db = create(:dashboard, user: other)
        get stats_api_v1_dashboard_path(other_db), headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end

    describe "PATCH /api/v1/dashboards/:id" do
      let(:dashboard) { create(:dashboard, user: user, name: "Old Name") }

      it "updates the name" do
        patch api_v1_dashboard_path(dashboard), params: { dashboard: { name: "New Name" } }, headers: headers
        expect(response).to have_http_status(:ok)
        expect(dashboard.reload.name).to eq("New Name")
      end

      it "cannot update another user's dashboard" do
        other_db = create(:dashboard, user: other, name: "Original")
        patch api_v1_dashboard_path(other_db), params: { dashboard: { name: "Hacked" } }, headers: headers
        expect(response).to have_http_status(:not_found)
        expect(other_db.reload.name).to eq("Original")
      end
    end

    describe "DELETE /api/v1/dashboards/:id" do
      let!(:dashboard) { create(:dashboard, user: user) }

      it "destroys the dashboard and returns no_content" do
        expect { delete api_v1_dashboard_path(dashboard), headers: headers }
          .to change(Dashboard, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end

      it "also destroys the dashboard's matches" do
        create_list(:match, 2, dashboard: dashboard)
        expect { delete api_v1_dashboard_path(dashboard), headers: headers }
          .to change(Match, :count).by(-2)
      end

      it "cannot delete another user's dashboard" do
        other_db = create(:dashboard, user: other)
        expect { delete api_v1_dashboard_path(other_db), headers: headers }
          .not_to change(Dashboard, :count)
        expect(response).to have_http_status(:not_found)
      end
    end

    describe "GET /api/v1/dashboards/:id/export" do
      let(:dashboard) { create(:dashboard, user: user) }

      it "returns a CSV file" do
        create(:match, :win, dashboard: dashboard, opponent_deck: :dragapult)
        get export_api_v1_dashboard_path(dashboard), headers: headers
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq("text/csv")
        expect(response.headers["Content-Disposition"]).to include("attachment")
      end

      it "includes the header row and match data" do
        create(:match, :win, dashboard: dashboard, opponent_deck: :dragapult, hand_quality: 4)
        get export_api_v1_dashboard_path(dashboard), headers: headers
        expect(response.body).to include("opponent_deck,result,game_mode")
        expect(response.body).to include("Dragapult")
        expect(response.body).to include("win")
      end

      it "only exports matches belonging to the dashboard" do
        create(:match, dashboard: dashboard, opponent_deck: :dragapult)
        other_db = create(:dashboard, user: other)
        create(:match, dashboard: other_db, opponent_deck: :raging_bolt)
        get export_api_v1_dashboard_path(dashboard), headers: headers
        expect(response.body).to include("Dragapult")
        expect(response.body).not_to include("Raging bolt")
      end

      it "returns 404 when exporting another user's dashboard" do
        other_db = create(:dashboard, user: other)
        get export_api_v1_dashboard_path(other_db), headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
