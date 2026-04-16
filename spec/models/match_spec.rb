require "rails_helper"

RSpec.describe Match, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:dashboard) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:opponent_deck) }
    it { is_expected.to validate_presence_of(:result) }
    it { is_expected.to validate_presence_of(:hand_quality) }
    it { is_expected.to validate_presence_of(:played_at) }

    it { is_expected.to validate_numericality_of(:hand_quality)
                          .only_integer
                          .is_greater_than_or_equal_to(1)
                          .is_less_than_or_equal_to(5) }

    it "allows number_of_mulligans to be nil" do
      expect(build(:match, number_of_mulligans: nil)).to be_valid
    end

    it "allows number_of_mulligans of 0 or more" do
      expect(build(:match, number_of_mulligans: 0)).to be_valid
      expect(build(:match, number_of_mulligans: 5)).to be_valid
    end

    it "rejects negative number_of_mulligans" do
      expect(build(:match, number_of_mulligans: -1)).not_to be_valid
    end

    it "rejects non-integer number_of_mulligans" do
      expect(build(:match, number_of_mulligans: 1.5)).not_to be_valid
    end
  end

  describe "enums" do
    it "defines opponent_deck enum with all expected decks" do
      expected_decks = %w[dragapult dragapult_dusknoir dragapult_blaziken tera_box team_rockets
                          raging_bolt alakazam mega_lucario absol green_ogerpon
                          clefairy_box garchomp ns_zoroark mega_starmie kengaskhan festival_lead grimmsnarl monkidori_froslass team_rocket_honchcrow crustle okidogi ceruledge slowpoke other]
      expect(Match.opponent_decks.keys).to match_array(expected_decks)
    end

    it "defines result enum with win and loss" do
      expect(Match.results.keys).to match_array(%w[win loss])
    end

    it "defines first_or_second enum with uninformed, first, and second" do
      expect(Match.first_or_seconds.keys).to match_array(%w[uninformed first second])
    end

    it "defines reason_for_defeat enum with all expected reasons" do
      expect(Match.reason_for_defeats.keys).to match_array(%w[unknown minor_misplay major_misplay disconnected])
    end

    it "defaults reason_for_defeat to nil" do
      expect(build(:match).reason_for_defeat).to be_nil
    end

    it "raises an ArgumentError for an invalid reason_for_defeat" do
      expect { build(:match, reason_for_defeat: "bad_play") }.to raise_error(ArgumentError)
    end

    it "defaults first_or_second to uninformed" do
      expect(build(:match).first_or_second).to eq("uninformed")
    end

    it "raises an ArgumentError for an invalid result" do
      expect { build(:match, result: "draw") }.to raise_error(ArgumentError)
    end

    it "raises an ArgumentError for an invalid opponent_deck" do
      expect { build(:match, opponent_deck: "pikachu") }.to raise_error(ArgumentError)
    end

    it "raises an ArgumentError for an invalid first_or_second" do
      expect { build(:match, first_or_second: "third") }.to raise_error(ArgumentError)
    end
  end

  describe "scopes" do
    let(:dashboard) { create(:dashboard) }

    before do
      create(:match, :win,  dashboard: dashboard)
      create(:match, :win,  dashboard: dashboard)
      create(:match, :loss, dashboard: dashboard)
    end

    it ".wins returns only won matches" do
      expect(Match.wins.count).to eq(2)
    end

    it ".losses returns only lost matches" do
      expect(Match.losses.count).to eq(1)
    end

    it ".recent orders by played_at descending" do
      other_dashboard = create(:dashboard)
      oldest = create(:match, dashboard: other_dashboard, played_at: 10.days.ago)
      newest = create(:match, dashboard: other_dashboard, played_at: 1.day.ago)
      scoped = other_dashboard.matches.recent
      expect(scoped.first).to eq(newest)
      expect(scoped.last).to eq(oldest)
    end
  end

  describe "factory" do
    it "is valid with default attributes" do
      expect(build(:match)).to be_valid
    end

    it "win trait produces a winning match" do
      expect(build(:match, :win).result).to eq("win")
    end

    it "loss trait produces a losing match" do
      expect(build(:match, :loss).result).to eq("loss")
    end
  end
end
