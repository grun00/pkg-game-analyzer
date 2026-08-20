require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:dashboards).dependent(:destroy) }
    it { is_expected.to have_many(:matches).through(:dashboards) }
    it { is_expected.to have_many(:creator_requests).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_length_of(:bio).is_at_most(200) }
  end

  describe "#display_name" do
    it "returns the name when present" do
      expect(build(:user, name: "Ash Ketchum").display_name).to eq("Ash Ketchum")
    end

    it "falls back to Creator #<id> when name is blank" do
      user = create(:user, name: nil)
      expect(user.display_name).to eq("Creator ##{user.id}")
    end
  end

  describe "enums" do
    it "defines role enum with regular, content_creator and admin" do
      expect(User.roles.keys).to match_array(%w[regular content_creator admin])
    end

    it "defaults new users to regular" do
      expect(create(:user).role).to eq("regular")
    end

    it "supports the content_creator trait" do
      expect(create(:user, :content_creator).role_content_creator?).to be(true)
    end

    it "supports the admin trait" do
      expect(create(:user, :admin).role_admin?).to be(true)
    end
  end

  describe "destroying a user" do
    it "also destroys associated dashboards and their matches" do
      user      = create(:user)
      dashboard = create(:dashboard, user: user)
      create_list(:match, 3, dashboard: dashboard)
      expect { user.destroy }.to change(Dashboard, :count).by(-1).and change(Match, :count).by(-3)
    end
  end
end
