require "rails_helper"

RSpec.describe Rating, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:content) }
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    subject { build(:rating) }

    it {
      is_expected.to validate_numericality_of(:stars)
        .only_integer
        .is_greater_than_or_equal_to(1)
        .is_less_than_or_equal_to(5)
    }

    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:content_id) }

    it "rejects zero stars" do
      expect(build(:rating, stars: 0)).not_to be_valid
    end

    it "rejects six stars" do
      expect(build(:rating, stars: 6)).not_to be_valid
    end

    it "allows one rating per user per content" do
      content = create(:content)
      user = create(:user)
      create(:rating, content: content, user: user)

      expect(build(:rating, content: content, user: user)).not_to be_valid
    end
  end

  describe "factory" do
    it "is valid with default attributes" do
      expect(build(:rating)).to be_valid
    end
  end
end
