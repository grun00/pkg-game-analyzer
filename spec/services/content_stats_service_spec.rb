require "rails_helper"

RSpec.describe ContentStatsService do
  let(:content) { create(:content) }
  subject(:stats) { described_class.new(content.ratings).call }

  context "when the content has no ratings" do
    it "returns a zero average and count" do
      expect(stats[:average_rating]).to eq(0.0)
      expect(stats[:ratings_count]).to eq(0)
    end

    it "returns a zeroed distribution for every star" do
      expect(stats[:by_star]).to eq((1..5).map { |s| { star: s, count: 0 } })
    end
  end

  context "when the content has ratings" do
    before do
      create(:rating, content: content, stars: 5)
      create(:rating, content: content, stars: 4)
      create(:rating, content: content, stars: 2)
    end

    it "counts the ratings" do
      expect(stats[:ratings_count]).to eq(3)
    end

    it "averages the stars rounded to two decimals" do
      expect(stats[:average_rating]).to eq(3.67)
    end

    it "builds the per-star distribution" do
      counts = stats[:by_star].to_h { |row| [row[:star], row[:count]] }
      expect(counts).to eq({ 1 => 0, 2 => 1, 3 => 0, 4 => 1, 5 => 1 })
    end
  end
end
