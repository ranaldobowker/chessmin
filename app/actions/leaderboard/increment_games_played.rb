module Leaderboard
  class IncrementGamesPlayed
    extend LightService::Action

    expects :player_one, :player_two

    executed do |ctx|
      ctx.player_one.increment!(:club_games_played)
      ctx.player_two.increment!(:club_games_played)
    end
  end
end
