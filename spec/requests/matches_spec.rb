require "rails_helper"

RSpec.describe "Matches", type: :request do
  let(:user)  { create(:user) }
  let(:other) { create(:user) }

  let(:valid_params) do
    {
      match: {
        opponent_deck: "charizard_ex",
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
    it "redirects GET /matches to sign in" do
      get matches_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects GET /matches/new to sign in" do
      get new_match_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects POST /matches to sign in" do
      post matches_path, params: valid_params
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "when authenticated" do
    before { sign_in user }

    describe "GET /matches" do
      it "returns http success" do
        get matches_path
        expect(response).to have_http_status(:ok)
      end

      it "only shows the current user's matches" do
        own         = create(:match, user: user,  opponent_deck: :charizard_ex)
        other_match = create(:match, user: other, opponent_deck: :gardevoir_ex)
        get matches_path
        expect(response.body).to include(own.opponent_deck.to_s.humanize)
        expect(response.body).not_to include(other_match.opponent_deck.to_s.humanize)
      end
    end

    describe "GET /matches/new" do
      it "returns http success" do
        get new_match_path
        expect(response).to have_http_status(:ok)
      end
    end

    describe "POST /matches" do
      it "creates a match and redirects to dashboard" do
        expect { post matches_path, params: valid_params }.to change(Match, :count).by(1)
        expect(response).to redirect_to(root_path)
      end

      it "scopes the new match to the current user" do
        post matches_path, params: valid_params
        expect(Match.last.user).to eq(user)
      end

      it "re-renders :new with unprocessable_entity on invalid data" do
        post matches_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Register a Match")
      end

      it "does not create a match on invalid data" do
        expect { post matches_path, params: invalid_params }.not_to change(Match, :count)
      end
    end

    describe "GET /matches/:id/edit" do
      let(:match) { create(:match, user: user) }

      it "returns http success for own match" do
        get edit_match_path(match)
        expect(response).to have_http_status(:ok)
      end

      it "redirects when accessing another user's match" do
        other_match = create(:match, user: other)
        get edit_match_path(other_match)
        expect(response).to redirect_to(matches_path)
      end
    end

    describe "PATCH /matches/:id" do
      let(:match) { create(:match, user: user, result: "loss") }

      it "updates the match and redirects to dashboard" do
        patch match_path(match), params: { match: { result: "win" } }
        expect(match.reload.result).to eq("win")
        expect(response).to redirect_to(root_path)
      end

      it "re-renders :edit with unprocessable_content on invalid data" do
        patch match_path(match), params: { match: { hand_quality: 9 } }
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "cannot update another user's match" do
        other_match = create(:match, user: other, result: "loss")
        patch match_path(other_match), params: { match: { result: "win" } }
        expect(response).to redirect_to(matches_path)
        expect(other_match.reload.result).to eq("loss")
      end
    end

    describe "DELETE /matches/:id" do
      let!(:match) { create(:match, user: user) }

      it "destroys the match and redirects" do
        expect { delete match_path(match) }.to change(Match, :count).by(-1)
        expect(response).to redirect_to(matches_path)
      end

      it "cannot delete another user's match" do
        other_match = create(:match, user: other)
        expect { delete match_path(other_match) }.not_to change(Match, :count)
      end
    end
  end
end
