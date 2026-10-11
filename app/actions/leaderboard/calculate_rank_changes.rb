module Leaderboard
  class CalculateRankChanges
    extend LightService::Action

    expects :player_one, :player_two, :result

    executed do |ctx|
      next ctx if ctx.player_one.current_rank == ctx.player_two.current_rank

      if ctx.result == "draw"
        apply_draw(ctx.player_one, ctx.player_two)
      else
        apply_win(ctx.player_one, ctx.player_two, ctx.result)
      end

      increment_games_played!(ctx.player_one, ctx.player_two)
    end

    class << self
      private

      def apply_draw(player_one, player_two)
        return if player_one.adjacent?(player_two)

        lower_ranked(player_one, player_two).gain_rank!
      end

      def apply_win(player_one, player_two, result)
        winner = result == "player_one" ? player_one : player_two
        loser  = result == "player_one" ? player_two : player_one

        return if winner.ranked_higher?(loser)

        higher = higher_ranked(player_one, player_two)
        lower  = lower_ranked(player_one, player_two)
        gain   = (lower.current_rank - higher.current_rank) / 2

        higher.lose_rank!
        lower.gain_rank!(gain)
      end

      def higher_ranked(player_one, player_two)
        player_one.ranked_higher?(player_two) ? player_one : player_two
      end

      def lower_ranked(player_one, player_two)
        player_one.ranked_lower?(player_two) ? player_one : player_two
      end

      def increment_games_played!(player_one, player_two)
        player_one.increment!(:club_games_played)
        player_two.increment!(:club_games_played)
      end
    end
  end
end
