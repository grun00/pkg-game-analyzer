require "rails_helper"

RSpec.describe Subscription, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:subscriber).class_name("User") }
    it { is_expected.to belong_to(:creator).class_name("User") }
  end

  describe "validations" do
    let(:subscriber) { create(:user) }
    let(:creator) { create(:user, :content_creator) }

    it "is valid for a regular user subscribing to a creator" do
      expect(build(:subscription, subscriber: subscriber, creator: creator)).to be_valid
    end

    it "rejects a duplicate subscription" do
      create(:subscription, subscriber: subscriber, creator: creator)
      dup = build(:subscription, subscriber: subscriber, creator: creator)
      expect(dup).not_to be_valid
    end

    it "rejects subscribing to a non-creator" do
      sub = build(:subscription, subscriber: subscriber, creator: create(:user))
      expect(sub).not_to be_valid
      expect(sub.errors[:creator]).to be_present
    end

    it "rejects subscribing to yourself" do
      sub = build(:subscription, subscriber: creator, creator: creator)
      expect(sub).not_to be_valid
      expect(sub.errors[:base]).to be_present
    end
  end
end
