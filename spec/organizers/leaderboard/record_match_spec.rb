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

    shared_examples "an invalid match" do |message|
      it "returns an error without changing ranks or game counts" do
        player_one
        player_two
        original_members = Member.order(:id).pluck(:current_rank, :club_games_played)

        expect(record_match.failure?).to be true
        expect(record_match.message).to eq(message)
        expect(Member.order(:id).pluck(:current_rank, :club_games_played)).to eq(original_members)
      end
    end

    context "when player one cannot be found" do
      let(:player_one_id) { -1 }
      let(:result)        { "draw" }

      include_examples "an invalid match", "Player one not found"
    end

    context "when a player cannot be found" do
      let(:player_two_id) { -1 }
      let(:result)        { "draw" }

      include_examples "an invalid match", "Player two not found"
    end

    context "when the same player is selected twice" do
      let(:player_two_id) { player_one.id }
      let(:result)        { "draw" }

      include_examples "an invalid match", "Players must be different"
    end

    context "when the result is invalid" do
      let(:result) { "invalid" }

      include_examples "an invalid match", "Invalid result: invalid"
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

        expect(player_one.reload.club_games_played).to eq(1)
        expect(player_two.reload.club_games_played).to eq(1)
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

        expect(player_one.reload.club_games_played).to eq(1)
        expect(player_two.reload.club_games_played).to eq(1)
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

      it "rounds half the gap up and rebalances the leaderboard" do
        record_match

        expect(player_one.reload.current_rank).to eq(4)
        expect(player_two.reload.current_rank).to eq(5)
        expect(Member.order(:current_rank).pluck(:current_rank)).to eq((1..8).to_a)
        expect(Member.order(:current_rank).pluck(:id)).to eq([
          members.fetch(0).id,
          members.fetch(1).id,
          members.fetch(3).id,
          members.fetch(2).id,
          members.fetch(7).id,
          members.fetch(4).id,
          members.fetch(5).id,
          members.fetch(6).id
        ])
      end
    end

    [ 2, 3 ].each do |gap|
      context "when targets collide with a gap of #{gap}" do
        let(:members)       { create_leaderboard(6) }
        let(:player_one)    { members.fetch(1) }
        let(:player_two)    { members.fetch(1 + gap) }
        let(:player_one_id) { player_one.id }
        let(:player_two_id) { player_two.id }
        let(:result)        { "player_two" }

        it "gives the winner the target and moves the loser one position below it" do
          record_match

          expect(player_two.reload.current_rank).to eq(3)
          expect(player_one.reload.current_rank).to eq(4)
          expect(Member.order(:current_rank).pluck(:current_rank)).to eq((1..6).to_a)
          expect(Member.where.not(id: [ player_one_id, player_two_id ]).order(:current_rank).pluck(:id))
            .to eq(members.map(&:id) - [ player_one_id, player_two_id ])
        end
      end
    end

    context "when player one wins against the second-last player" do
      let(:members)       { create_leaderboard(5) }
      let(:player_one)    { members.last }
      let(:player_two)    { members.fetch(3) }
      let(:player_one_id) { player_one.id }
      let(:player_two_id) { player_two.id }
      let(:result)        { "player_one" }

      it "swaps the bottom two players without leaving a gap" do
        record_match

        expect(player_one.reload.current_rank).to eq(4)
        expect(player_two.reload.current_rank).to eq(5)
        expect(Member.order(:current_rank).pluck(:id)).to eq(
          members.first(3).map(&:id) + [ player_one_id, player_two_id ]
        )
        expect(Member.order(:current_rank).pluck(:current_rank)).to eq((1..5).to_a)
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

        expect(record_match.success?).to be true
      end

      it "rolls back ranks and game counts if the second counter update fails" do
        members
        original_members = Member.order(:id).pluck(:current_rank, :club_games_played)

        allow(Member).to receive(:find_by).and_call_original
        allow(Member).to receive(:find_by).with(id: player_two_id).and_return(player_two)
        allow(player_two).to receive(:increment!).with(:club_games_played)
          .and_raise(ActiveRecord::ActiveRecordError, "Counter update failed")

        expect { record_match }.to raise_error(ActiveRecord::ActiveRecordError, "Counter update failed")
        expect(Member.order(:id).pluck(:current_rank, :club_games_played)).to eq(original_members)
      end
    end
  end

  private

  def create_leaderboard(size)
    Array.new(size) { create(:member, club_games_played: 0) }
  end
end
