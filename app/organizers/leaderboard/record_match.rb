module Leaderboard
  class RecordMatch
    extend LightService::Organizer

    def self.call(player_one_id:, player_two_id:, result:)
      with(
        player_one_id:,
        player_two_id:,
        result:
      ).reduce(
        LoadPlayers,
        ValidateMatch,
        CalculateRankChanges
      )
    end
  end
end
