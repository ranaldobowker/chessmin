require "rails_helper"

RSpec.describe Leaderboard::RecordMatch, type: :service do
  subject(:record_match) do
    described_class.call(
      player_one_id: player_one_id,
      player_two_id: player_two_id,
      result:        result
    )
  end

  describe "validation" do
    let(:player_one)    { create(:member, club_games_played: 0) }
    let(:player_two)    { create(:member, club_games_played: 0) }
    let(:player_one_id) { player_one.id }
    let(:player_two_id) { player_two.id }

    context "when a player cannot be found" do
      let(:player_two_id) { -1 }
      let(:result)        { "draw" }

      it "returns a failed context" do
        expect(record_match.failure?).to be true
        expect(record_match.message).to eq("Player two not found")
      end
    end

    context "when the same player is selected twice" do
      let(:player_two_id) { player_one.id }
      let(:result)        { "draw" }

      it "returns a failed context" do
        expect(record_match.failure?).to be true
        expect(record_match.message).to  eq("Players must be different")
      end
    end

    context "when the result is invalid" do
      let(:result) { "invalid" }

      it "returns a failed context" do
        expect(record_match.failure?).to be true
        expect(record_match.message).to  eq("Invalid result: invalid")
      end
    end
  end

  describe "ranking" do
    context "when the higher-ranked player wins" do
      let(:members)       { create_leaderboard(6) }
      let(:player_one)    { members.fetch(2) }
      let(:player_two)    { members.fetch(5) }
      let(:player_one_id) { player_one.id }
      let(:player_two_id) { player_two.id }
      let(:result)        { "player_one" }

      it "leaves the leaderboard ranks unchanged" do
        members

        expect { record_match }
          .not_to change { Member.order(:current_rank).pluck(:id, :current_rank) }
      end
    end

    context "when adjacent players draw" do
      let(:members)       { create_leaderboard(4) }
      let(:player_one)    { members.fetch(2) }
      let(:player_two)    { members.fetch(3) }
      let(:player_one_id) { player_one.id }
      let(:player_two_id) { player_two.id }
      let(:result)        { "draw" }

      it "leaves the leaderboard ranks unchanged" do
        members

        expect { record_match }
          .not_to change { Member.order(:current_rank).pluck(:id, :current_rank) }
      end
    end

    context "when non-adjacent players draw" do
      let(:members)       { create_leaderboard(6) }
      let(:player_one)    { members.fetch(2) }
      let(:player_two)    { members.fetch(5) }
      let(:player_one_id) { player_one.id }
      let(:player_two_id) { player_two.id }
      let(:result)        { "draw" }

      it "moves the lower-ranked player up and rebalances the leaderboard" do
        record_match

        expect(player_one.reload.current_rank).to eq(3)
        expect(player_two.reload.current_rank).to eq(5)
        expect(members.fetch(4).reload.current_rank).to eq(6)
        expect(Member.order(:current_rank).pluck(:current_rank)).to eq((1..6).to_a)
      end
    end

    context "when the lower-ranked player wins" do
      let(:members)       { create_leaderboard(8) }
      let(:player_one)    { members.fetch(2) }
      let(:player_two)    { members.fetch(7) }
      let(:player_one_id) { player_one.id }
      let(:player_two_id) { player_two.id }
      let(:result)        { "player_two" }

      it "moves both players and rebalances the leaderboard" do
        record_match

        expect(player_one.reload.current_rank).to eq(4)
        expect(player_two.reload.current_rank).to eq(6)
        expect(Member.order(:current_rank).pluck(:current_rank)).to eq((1..8).to_a)
        expect(Member.order(:current_rank).pluck(:id)).to eq([
          members.fetch(0).id,
          members.fetch(1).id,
          members.fetch(3).id,
          members.fetch(2).id,
          members.fetch(4).id,
          members.fetch(7).id,
          members.fetch(5).id,
          members.fetch(6).id
        ])
      end
    end

    context "when the players are ranked 10th and 16th" do
      let(:members)       { create_leaderboard(16) }
      let(:player_one)    { members.fetch(9) }
      let(:player_two)    { members.fetch(15) }
      let(:player_one_id) { player_one.id }
      let(:player_two_id) { player_two.id }
      let(:result)        { "player_two" }

      it "moves the higher-ranked player down one and the winner up half the gap" do
        record_match

        expect(player_one.reload.current_rank).to eq(11)
        expect(player_two.reload.current_rank).to eq(13)
      end
    end

    context "when a match is recorded" do
      let(:members)       { create_leaderboard(6) }
      let(:player_one)    { members.fetch(2) }
      let(:player_two)    { members.fetch(5) }
      let(:player_one_id) { player_one.id }
      let(:player_two_id) { player_two.id }
      let(:result)        { "draw" }

      it "increments both players' games played" do
        expect { record_match }
          .to change  { player_one.reload.club_games_played }.by(1)
          .and change { player_two.reload.club_games_played }.by(1)
      end
    end
  end

  private

  def create_leaderboard(size)
    Array.new(size) { create(:member, club_games_played: 0) }
  end
end
