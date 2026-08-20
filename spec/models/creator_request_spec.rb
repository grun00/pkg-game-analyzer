require "rails_helper"

RSpec.describe CreatorRequest, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_length_of(:proposed_bio).is_at_most(200) }
  end

  describe "enums" do
    it "defines status enum with pending, approved and rejected" do
      expect(CreatorRequest.statuses.keys).to match_array(%w[pending approved rejected])
    end

    it "defaults new requests to pending" do
      expect(create(:creator_request).status).to eq("pending")
    end
  end

  describe "one-pending-per-user validation" do
    let(:user) { create(:user) }

    it "allows a first pending request" do
      expect(build(:creator_request, user: user)).to be_valid
    end

    it "rejects a second pending request for the same user" do
      create(:creator_request, user: user)
      dup = build(:creator_request, user: user)
      expect(dup).not_to be_valid
      expect(dup.errors[:base]).to be_present
    end

    it "allows a new request when the previous one is resolved" do
      create(:creator_request, :approved, user: user)
      expect(build(:creator_request, user: user)).to be_valid
    end

    it "allows pending requests for different users" do
      create(:creator_request, user: user)
      expect(build(:creator_request, user: create(:user))).to be_valid
    end
  end
end
