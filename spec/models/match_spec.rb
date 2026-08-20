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

    it "allows my_battlefield to be nil" do
      expect(build(:match, my_battlefield: nil)).to be_valid
    end

    it "allows opponent_battlefield to be nil" do
      expect(build(:match, opponent_battlefield: nil)).to be_valid
    end

    it "treats a blank battlefield as nil" do
      match = build(:match, my_battlefield: "", opponent_battlefield: "")
      expect(match).to be_valid
      match.validate
      expect(match.my_battlefield).to be_nil
      expect(match.opponent_battlefield).to be_nil
    end

    it "allows a valid battlefield value" do
      expect(build(:match, my_battlefield: "kinkou_temple",
                           opponent_battlefield: "void_gate")).to be_valid
    end

    it "rejects an unknown battlefield value" do
      expect(build(:match, my_battlefield: "not_a_place")).not_to be_valid
    end
  end

  describe "enums" do
    it "defines opponent_deck enum with all expected decks" do
      expected_decks = %w[dragapult dragapult_dusknoir dragapult_blaziken tera_box team_rockets
                          raging_bolt alakazam mega_lucario absol green_ogerpon
                          clefairy_box garchomp ns_zoroark mega_starmie kengaskhan festival_lead grimmsnarl monkidori_froslass team_rocket_honchcrow crustle okidogi ceruledge slowpoke slop_box greninja_ex mega_excradrill other
                          kaisa master_yi ahri viktor jinx lee_sin yasuo vi darius volibear annie garen
                          ahri_nine_tailed_fox akali_rogue_assassin ambessa_matriarch_of_war annie_dark_child
                          azir_emperor_of_the_sands darius_hand_of_noxus diana_scorn_of_the_moon
                          draven_glorious_executioner ezreal_prodigal_explorer fiora_grand_duelist
                          garen_might_of_demacia irelia_blade_dancer ivern_green_father jax_grandmaster_at_arms
                          jayce_defender_of_tomorrow jhin_virtuoso jinx_loose_cannon kaisa_daughter_of_the_void
                          khazix_voidreaver leblanc_deceiver lee_sin_blind_monk leona_radiant_dawn
                          lillia_bashful_bloom lucian_purifier lux_lady_of_luminosity master_yi_wuju_bladesman
                          master_yi_wuju_master mel_souls_reflection miss_fortune_bounty_hunter
                          nasus_curator_of_the_sands ornn_fire_below_the_mountain poppy_keeper_of_the_hammer
                          pyke_bloodharbor_ripper reksai_void_burrower renata_glasc_chem_baroness
                          renekton_butcher_of_the_sands rengar_pridestalker rumble_mechanized_menace
                          sett_the_boss shen_eye_of_twilight sivir_battle_mistress teemo_swift_scout
                          vex_gloomist vi_piltover_enforcer viktor_herald_of_the_arcane
                          volibear_relentless_storm yasuo_unforgiven yordle_kennen_heart_of_the_tempest
                          zed_master_of_shadows]
      expect(Match.opponent_decks.keys).to match_array(expected_decks)
    end

    it "assigns new riftbound deck integers without reusing existing ones" do
      expect(Match::OPPONENT_DECKS[:kaisa]).to eq(27)
      expect(Match::OPPONENT_DECKS[:garen]).to eq(38)
      expect(Match::OPPONENT_DECKS[:ahri_nine_tailed_fox]).to eq(39)
      expect(Match::OPPONENT_DECKS[:zed_master_of_shadows]).to eq(87)
    end

    it "defines result enum with win, loss, and tie" do
      expect(Match.results.keys).to match_array(%w[win loss tie])
    end

    it "defines first_or_second enum with uninformed, first, and second" do
      expect(Match.first_or_seconds.keys).to match_array(%w[uninformed first second])
    end

    it "defines game_mode enum with in_person, tcg_live, standard, limited, bo1, and bo3" do
      expect(Match.game_modes.keys).to match_array(%w[in_person tcg_live standard limited bo1 bo3])
    end

    it "assigns new riftbound game_mode integers" do
      expect(Match::GAME_MODES[:standard]).to eq(2)
      expect(Match::GAME_MODES[:limited]).to eq(3)
      expect(Match::GAME_MODES[:bo1]).to eq(4)
      expect(Match::GAME_MODES[:bo3]).to eq(5)
    end

    it "defaults game_mode to in_person" do
      match = Match.create!(dashboard: create(:dashboard), opponent_deck: :dragapult,
                            result: "win", hand_quality: 3, played_at: Time.current)
      expect(match.reload.game_mode).to eq("in_person")
    end

    it "defines reason_for_defeat enum with all expected reasons" do
      expect(Match.reason_for_defeats.keys).to match_array(%w[unknown minor_misplay major_misplay disconnected unlucky])
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
