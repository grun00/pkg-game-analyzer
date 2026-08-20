require "rails_helper"

RSpec.describe Dashboard, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:matches).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "enums" do
    it {
      is_expected.to define_enum_for(:game_type)
        .with_values(pokemon: 0, magic: 1, riftbound: 2).with_prefix
    }

    it "defaults game_type to pokemon" do
      expect(build(:dashboard).game_type).to eq("pokemon")
    end
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
