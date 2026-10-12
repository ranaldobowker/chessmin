module Leaderboard
  class CalculateRankChanges
    extend LightService::Action

    expects :player_one, :player_two, :result
    promises :rank_changes

    executed do |ctx|
      ctx.rank_changes = []

      if ctx.result == "draw"
        ctx.rank_changes = draw_changes(ctx.player_one, ctx.player_two)
      else
        ctx.rank_changes = win_changes(ctx.player_one, ctx.player_two, ctx.result)
      end
    end

    class << self
      private

      def draw_changes(player_one, player_two)
        return [] if player_one.adjacent?(player_two)

        lower = player_one.ranked_lower?(player_two) ? player_one : player_two

        [ [ lower.id, lower.current_rank - 1 ] ]
      end

      def win_changes(player_one, player_two, result)
        winner = result == "player_one" ? player_one : player_two
        loser  = result == "player_one" ? player_two : player_one

        return [] if winner.ranked_higher?(loser)

        gain          = ((winner.current_rank - loser.current_rank) / 2.0).round
        winner_target = winner.current_rank - gain
        loser_target  = loser.current_rank + 1
        loser_target += 1 if loser_target == winner_target

        [ [ winner.id, winner_target ], [ loser.id, loser_target ] ]
      end
    end
  end
end
