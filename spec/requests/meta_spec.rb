require "rails_helper"

RSpec.describe "Api::V1::Meta", type: :request do
  let(:user)    { create(:user) }
  let(:headers) { auth_headers(user) }

  def json
    JSON.parse(response.body)
  end

  def deck_values
    json["opponent_decks"].map { |o| o["value"] }
  end

  def mode_values
    json["game_modes"].map { |o| o["value"] }
  end

  it "requires authentication" do
    get "/api/v1/meta", as: :json
    expect(response).to have_http_status(:unauthorized)
  end

  describe "GET /api/v1/meta (default pokemon)" do
    it "returns pokemon decks and game modes plus shared sets" do
      get "/api/v1/meta", headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(deck_values).to include("dragapult", "other")
      expect(deck_values).not_to include("kaisa")
      expect(mode_values).to match_array(%w[in_person tcg_live])
      expect(json["results"].map { |o| o["value"] }).to match_array(%w[win loss tie])
      expect(json["reasons_for_defeat"].map { |o| o["value"] })
        .to match_array(%w[unknown minor_misplay major_misplay disconnected unlucky])
      expect(json["hand_qualities"].size).to eq(5)
    end
  end

  describe "GET /api/v1/meta?game_type=riftbound" do
    it "returns riftbound decks and modes plus shared reasons" do
      get "/api/v1/meta", params: { game_type: "riftbound" }, headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(deck_values).to include("kaisa", "other")
      expect(deck_values).not_to include("dragapult")
      expect(mode_values).to match_array(%w[standard limited])
      expect(json["reasons_for_defeat"].map { |o| o["value"] })
        .to match_array(%w[unknown minor_misplay major_misplay disconnected unlucky])
    end
  end

  describe "GET /api/v1/meta?game_type=magic" do
    it "returns only the other deck, no game modes, and shared reasons" do
      get "/api/v1/meta", params: { game_type: "magic" }, headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(deck_values).to eq(["other"])
      expect(json["game_modes"]).to eq([])
      expect(json["reasons_for_defeat"]).to be_present
    end
  end

  describe "GET /api/v1/meta with an unknown game_type" do
    it "falls back to pokemon" do
      get "/api/v1/meta", params: { game_type: "xyz" }, headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(deck_values).to include("dragapult")
      expect(mode_values).to match_array(%w[in_person tcg_live])
    end
  end
end
