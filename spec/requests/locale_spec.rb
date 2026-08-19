require "rails_helper"

RSpec.describe "Locale selection", type: :request do
  let(:user)    { create(:user) }
  let(:headers) { auth_headers(user) }

  def json
    JSON.parse(response.body)
  end

  describe "meta labels" do
    it "defaults to English when no locale is requested" do
      get api_v1_meta_path, headers: headers
      result = json["results"].find { |r| r["value"] == "win" }
      expect(result["label"]).to eq("WIN")
    end

    it "localizes labels from the ?locale= parameter" do
      get api_v1_meta_path, headers: headers, params: { locale: "pt-BR" }
      reason = json["reasons_for_defeat"].find { |r| r["value"] == "unlucky" }
      expect(reason["label"]).to eq("Azar")
    end

    it "localizes labels from the Accept-Language header" do
      get api_v1_meta_path, headers: headers.merge("Accept-Language" => "pt-BR,pt;q=0.9")
      mode = json["game_modes"].find { |m| m["value"] == "in_person" }
      expect(mode["label"]).to eq("Presencial")
    end

    it "prefers the ?locale= parameter over the Accept-Language header" do
      get api_v1_meta_path,
        headers: headers.merge("Accept-Language" => "pt-BR"),
        params: { locale: "en" }
      mode = json["game_modes"].find { |m| m["value"] == "in_person" }
      expect(mode["label"]).to eq("In person")
    end

    it "falls back to the default for an unsupported locale" do
      get api_v1_meta_path, headers: headers, params: { locale: "fr" }
      result = json["results"].find { |r| r["value"] == "win" }
      expect(result["label"]).to eq("WIN")
    end
  end

  describe "error messages" do
    let(:dashboard) { create(:dashboard, user: user) }

    it "returns the not-found error in English by default" do
      get api_v1_dashboard_path(-1), headers: headers
      expect(response).to have_http_status(:not_found)
      expect(json["error"]).to eq("Not found")
    end

    it "returns the not-found error in Portuguese" do
      get api_v1_dashboard_path(-1), headers: headers, params: { locale: "pt-BR" }
      expect(response).to have_http_status(:not_found)
      expect(json["error"]).to eq("Não encontrado")
    end
  end

  describe "CSV export" do
    let(:dashboard) { create(:dashboard, user: user) }

    before do
      create(:match, :win, dashboard: dashboard, opponent_deck: :dragapult)
    end

    it "localizes headers and enum values in Portuguese" do
      get export_api_v1_dashboard_path(dashboard), headers: headers, params: { locale: "pt-BR" }
      expect(response.body).to include("deck_adversario,resultado,modo_de_jogo")
      expect(response.body).to include("VIT")
    end
  end
end
