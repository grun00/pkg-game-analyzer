require "rails_helper"

RSpec.describe "Dashboards", type: :request do
  let(:user)  { create(:user) }
  let(:other) { create(:user) }

  context "when not authenticated" do
    it "redirects GET / to sign in" do
      get root_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects GET /dashboards to sign in" do
      get dashboards_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "when authenticated" do
    before { sign_in user }

    describe "GET / (index)" do
      it "returns http success" do
        get root_path
        expect(response).to have_http_status(:ok)
      end

      it "lists only the current user's dashboards" do
        own   = create(:dashboard, user: user,  name: "My Deck Tracker")
        other_db = create(:dashboard, user: other, name: "Rival Tracker")
        get dashboards_path
        expect(response.body).to include("My Deck Tracker")
        expect(response.body).not_to include("Rival Tracker")
      end
    end

    describe "GET /dashboards/new" do
      it "returns http success" do
        get new_dashboard_path
        expect(response).to have_http_status(:ok)
      end
    end

    describe "POST /dashboards" do
      it "creates a dashboard and redirects to its show page" do
        expect { post dashboards_path, params: { dashboard: { name: "Regionals" } } }
          .to change(Dashboard, :count).by(1)
        expect(response).to redirect_to(dashboard_path(Dashboard.last))
      end

      it "scopes the new dashboard to the current user" do
        post dashboards_path, params: { dashboard: { name: "Regionals" } }
        expect(Dashboard.last.user).to eq(user)
      end

      it "re-renders new with unprocessable_content when name is blank" do
        expect { post dashboards_path, params: { dashboard: { name: "" } } }
          .not_to change(Dashboard, :count)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    describe "GET /dashboards/:id (show/stats)" do
      let(:dashboard) { create(:dashboard, user: user) }

      it "returns http success" do
        get dashboard_path(dashboard)
        expect(response).to have_http_status(:ok)
      end

      it "shows the empty state when the dashboard has no matches" do
        get dashboard_path(dashboard)
        expect(response.body).to include("No matches recorded yet")
      end

      it "shows stats when the dashboard has matches" do
        create(:match, :win,  dashboard: dashboard)
        create(:match, :loss, dashboard: dashboard)
        get dashboard_path(dashboard)
        expect(response.body).to include("Win Rate")
      end

      it "does not show stats from another user's dashboard" do
        other_db = create(:dashboard, user: other)
        create(:match, :win, dashboard: other_db)
        get dashboard_path(dashboard)
        expect(response.body).to include("No matches recorded yet")
      end

      it "redirects when accessing another user's dashboard" do
        other_db = create(:dashboard, user: other)
        get dashboard_path(other_db)
        expect(response).to redirect_to(dashboards_path)
      end
    end

    describe "GET /dashboards/:id/edit" do
      it "returns http success for own dashboard" do
        db = create(:dashboard, user: user)
        get edit_dashboard_path(db)
        expect(response).to have_http_status(:ok)
      end

      it "redirects when accessing another user's dashboard" do
        other_db = create(:dashboard, user: other)
        get edit_dashboard_path(other_db)
        expect(response).to redirect_to(dashboards_path)
      end
    end

    describe "PATCH /dashboards/:id" do
      let(:dashboard) { create(:dashboard, user: user, name: "Old Name") }

      it "updates the name and redirects to show" do
        patch dashboard_path(dashboard), params: { dashboard: { name: "New Name" } }
        expect(dashboard.reload.name).to eq("New Name")
        expect(response).to redirect_to(dashboard_path(dashboard))
      end

      it "cannot update another user's dashboard" do
        other_db = create(:dashboard, user: other, name: "Original")
        patch dashboard_path(other_db), params: { dashboard: { name: "Hacked" } }
        expect(response).to redirect_to(dashboards_path)
        expect(other_db.reload.name).to eq("Original")
      end
    end

    describe "DELETE /dashboards/:id" do
      let!(:dashboard) { create(:dashboard, user: user) }

      it "destroys the dashboard and redirects to index" do
        expect { delete dashboard_path(dashboard) }.to change(Dashboard, :count).by(-1)
        expect(response).to redirect_to(dashboards_path)
      end

      it "also destroys the dashboard's matches" do
        create_list(:match, 2, dashboard: dashboard)
        expect { delete dashboard_path(dashboard) }.to change(Match, :count).by(-2)
      end

      it "cannot delete another user's dashboard" do
        other_db = create(:dashboard, user: other)
        expect { delete dashboard_path(other_db) }.not_to change(Dashboard, :count)
      end
    end
  end
end
