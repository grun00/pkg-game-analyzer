require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:dashboards).dependent(:destroy) }
    it { is_expected.to have_many(:matches).through(:dashboards) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_presence_of(:password) }
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
