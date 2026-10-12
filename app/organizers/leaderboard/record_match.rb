module Leaderboard
  class RecordMatch
    extend LightService::Organizer

    def self.call(player_one_id:, player_two_id:, result:)
      Member.transaction do
        with(
          player_one_id:,
          player_two_id:,
          result:
        ).reduce(
          LoadPlayers,
          ValidateMatch,
          CalculateRankChanges,
          RebalanceRanks,
          IncrementGamesPlayed
        )
      end
    end
  end
end
