require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  describe "GET /" do
    context "when not authenticated" do
      it "redirects to the sign-in page" do
        get root_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated" do
      let(:user) { create(:user) }

      before { sign_in user }

      it "returns http success" do
        get root_path
        expect(response).to have_http_status(:ok)
      end

      it "renders the dashboard page" do
        get root_path
        expect(response.body).to include("Dashboard")
      end

      it "shows stats when user has matches" do
        create(:match, :win,  user: user)
        create(:match, :loss, user: user)
        get root_path
        expect(response.body).to include("Win Rate")
      end

      it "shows empty state when user has no matches" do
        get root_path
        expect(response.body).to include("No matches recorded yet")
      end

      it "does not leak another user's data" do
        other = create(:user)
        create(:match, :win, user: other, opponent_deck: :iron_thorns)
        get root_path
        expect(response.body).to include("No matches recorded yet")
      end
    end
  end
end
