require "rails_helper"

RSpec.describe Leaderboard::ApplyMatchResult, type: :service do
  subject(:apply_result) { described_class.new(player_one:, player_two:, result:).call }

  let(:player_one)      { member_at(10) }
  let(:player_two)      { member_at(player_two_rank) }
  let(:player_two_rank) { 16 }

  def member_at(rank)
    create(:member).tap { |member| member.update_column(:current_rank, rank) }
  end

  context "when the higher-ranked player wins" do
    let(:result) { "player_one" }

    it "does not change either rank" do
      expect { apply_result }.not_to change { [ player_one.reload.current_rank, player_two.reload.current_rank ] }
    end
  end

  context "when the players draw" do
    let(:result) { "draw" }

    context "when they are adjacent" do
      let(:player_two_rank) { 11 }

      it "does not change either rank" do
        expect { apply_result }.not_to change { [ player_one.reload.current_rank, player_two.reload.current_rank ] }
      end
    end

    it "moves the lower-ranked player up one position" do
      expect { apply_result }.to change { player_two.reload.current_rank }.from(16).to(15)
    end
  end

  context "when the lower-ranked player wins" do
    let(:result) { "player_two" }

    it "moves the higher-ranked player down one and the winner up half the gap" do
      expect { apply_result }
        .to change  { player_one.reload.current_rank }.from(10).to(11)
        .and change { player_two.reload.current_rank }.from(16).to(13)
    end
  end

  context "when both players have the same rank" do
    let(:player_two_rank) { 10 }
    let(:result)          { "player_two" }

    it "does not change either rank" do
      expect { apply_result }.not_to change { [ player_one.reload.current_rank, player_two.reload.current_rank ] }
    end
  end

  context "when a match is played" do
    let(:result) { "draw" }

    it "increments both players' games played" do
      expect { apply_result }
        .to change  { player_one.reload.club_games_played }.by(1)
        .and change { player_two.reload.club_games_played }.by(1)
    end
  end
end
