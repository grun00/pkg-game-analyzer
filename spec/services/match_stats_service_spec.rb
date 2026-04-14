require "rails_helper"

RSpec.describe MatchStatsService do
  let(:user) { create(:user) }
  subject(:stats) { described_class.new(user.matches).call }

  context "when the user has no matches" do
    it "returns zeros for all counts" do
      expect(stats[:total]).to eq(0)
      expect(stats[:wins]).to eq(0)
      expect(stats[:losses]).to eq(0)
    end

    it "returns 0.0 win rate" do
      expect(stats[:win_rate]).to eq(0.0)
    end

    it "returns 0.0 average hand quality" do
      expect(stats[:average_hand_quality]).to eq(0.0)
    end

    it "returns empty by_deck list" do
      expect(stats[:by_deck]).to be_empty
    end

    it "returns by_hand_quality for all 5 ratings with zero totals" do
      expect(stats[:by_hand_quality].map { |r| r[:quality] }).to eq([1, 2, 3, 4, 5])
      expect(stats[:by_hand_quality].all? { |r| r[:total].zero? }).to be true
    end

    it "returns empty recent_matches" do
      expect(stats[:recent_matches]).to be_empty
    end
  end

  context "when the user has matches" do
    before do
      create(:match, :win,  user: user, opponent_deck: :charizard_ex, hand_quality: 5, played_at: 3.days.ago)
      create(:match, :win,  user: user, opponent_deck: :charizard_ex, hand_quality: 4, played_at: 2.days.ago)
      create(:match, :loss, user: user, opponent_deck: :charizard_ex, hand_quality: 2, played_at: 1.day.ago)
      create(:match, :loss, user: user, opponent_deck: :gardevoir_ex, hand_quality: 3, played_at: 4.days.ago)
    end

    it "counts total matches correctly" do
      expect(stats[:total]).to eq(4)
    end

    it "counts wins correctly" do
      expect(stats[:wins]).to eq(2)
    end

    it "counts losses correctly" do
      expect(stats[:losses]).to eq(2)
    end

    it "calculates win rate as a percentage" do
      expect(stats[:win_rate]).to eq(50.0)
    end

    it "calculates average hand quality" do
      # (5 + 4 + 2 + 3) / 4 = 3.5
      expect(stats[:average_hand_quality]).to eq(3.5)
    end

    it "groups results by deck and sorts by total descending" do
      charizard = stats[:by_deck].find { |d| d[:deck] == :charizard_ex }
      expect(charizard[:total]).to eq(3)
      expect(charizard[:wins]).to eq(2)
      expect(charizard[:losses]).to eq(1)
      expect(charizard[:win_rate]).to eq(66.7)
    end

    it "excludes decks with no matches from by_deck" do
      deck_names = stats[:by_deck].map { |d| d[:deck] }
      expect(deck_names).to contain_exactly(:charizard_ex, :gardevoir_ex)
    end

    it "lists by_hand_quality for all 5 quality levels" do
      expect(stats[:by_hand_quality].map { |r| r[:quality] }).to eq([1, 2, 3, 4, 5])
    end

    it "calculates win_rate correctly per hand quality" do
      quality_5 = stats[:by_hand_quality].find { |r| r[:quality] == 5 }
      expect(quality_5[:win_rate]).to eq(100.0)

      quality_2 = stats[:by_hand_quality].find { |r| r[:quality] == 2 }
      expect(quality_2[:win_rate]).to eq(0.0)
    end

    it "returns at most 5 recent matches ordered by played_at desc" do
      create_list(:match, 3, user: user, played_at: 5.days.ago)
      expect(stats[:recent_matches].count).to eq(5)
    end
  end
end
