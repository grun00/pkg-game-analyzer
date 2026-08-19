require "rails_helper"

# Exercises the `require_creator!` guard defined in Api::V1::BaseController via a
# throwaway controller + route. No creator-gated endpoint exists in Phase 1 yet,
# so this keeps the guard covered until content endpoints arrive.
class CreatorOnlyProbeController < Api::V1::BaseController
  before_action :require_creator!

  def index
    head :ok
  end
end

RSpec.describe "require_creator! guard", type: :request do
  let(:regular) { create(:user) }
  let(:creator) { create(:user, :content_creator) }

  before do
    Rails.application.routes.draw do
      get "/creator_only_probe", to: "creator_only_probe#index"
    end
  end

  after { Rails.application.reload_routes! }

  it "returns 403 for a regular user" do
    get "/creator_only_probe", headers: encoded_auth_headers(regular)
    expect(response).to have_http_status(:forbidden)
    expect(JSON.parse(response.body)["error"]).to be_present
  end

  it "returns 200 for a content creator" do
    get "/creator_only_probe", headers: encoded_auth_headers(creator)
    expect(response).to have_http_status(:ok)
  end
end
