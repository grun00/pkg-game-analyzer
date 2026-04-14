require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:matches).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_presence_of(:password) }
  end

  describe "destroying a user" do
    it "also destroys associated matches" do
      user  = create(:user)
      create_list(:match, 3, user: user)
      expect { user.destroy }.to change(Match, :count).by(-3)
    end
  end
end
