require "rails_helper"

RSpec.describe Dashboard, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:matches).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "factory" do
    it "is valid with default attributes" do
      expect(build(:dashboard)).to be_valid
    end
  end

  describe "destroying a dashboard" do
    it "also destroys its matches" do
      dashboard = create(:dashboard)
      create_list(:match, 4, dashboard: dashboard)
      expect { dashboard.destroy }.to change(Match, :count).by(-4)
    end
  end
end
