require "rails_helper"

RSpec.describe Content, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:creator).class_name("User") }
    it { is_expected.to have_many(:ratings).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:body) }
  end

  describe "enums" do
    it "defines content_type with article and guide" do
      expect(Content.content_types.keys).to match_array(%w[article guide])
    end

    it "defines status with draft and published" do
      expect(Content.statuses.keys).to match_array(%w[draft published])
    end

    it "defaults content_type to article and status to draft" do
      content = build(:content, :draft)
      expect(content.content_type).to eq("article")
      expect(content.status).to eq("draft")
    end

    it "raises an ArgumentError for an invalid content_type" do
      expect { build(:content, content_type: "video") }.to raise_error(ArgumentError)
    end
  end

  describe "published_at syncing" do
    it "stamps published_at when a draft is published" do
      content = create(:content, :draft)
      expect(content.published_at).to be_nil

      content.update!(status: :published)
      expect(content.reload.published_at).to be_present
    end

    it "clears published_at when reverted to draft" do
      content = create(:content, status: :published, published_at: 2.days.ago)

      content.update!(status: :draft)
      expect(content.reload.published_at).to be_nil
    end

    it "does not overwrite an existing published_at on re-save" do
      content = create(:content, status: :published)
      original = content.published_at

      content.update!(title: "New title")
      expect(content.reload.published_at).to be_within(1.second).of(original)
    end
  end

  describe "scopes" do
    it ".published returns only published content" do
      published = create(:content, status: :published)
      create(:content, :draft)

      expect(Content.published).to contain_exactly(published)
    end
  end

  describe "factory" do
    it "is valid with default attributes" do
      expect(build(:content)).to be_valid
    end

    it "draft trait produces an unpublished content" do
      expect(build(:content, :draft).status).to eq("draft")
    end
  end
end
