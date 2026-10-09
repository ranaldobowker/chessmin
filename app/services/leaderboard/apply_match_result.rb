module Leaderboard
  class ApplyMatchResult
    attr_reader :player_one, :player_two, :result

    def initialize(player_one:, player_two:, result:)
      @player_one = player_one
      @player_two = player_two
      @result     = result
    end

    def call
      return if player_one.current_rank == player_two.current_rank # unsupported scenario

      case result
      when "draw"
        apply_draw
      when "player_one", "player_two"
        apply_win
      else
        raise ArgumentError, "Invalid result: #{result}"
      end
    end

    private

    def apply_draw
      return if player_one.adjacent?(player_two) # no change in ranking takes place

      lower_ranked.gain_rank!
    end

    def apply_win
      return if winner.ranked_higher?(loser) # no change in ranking takes place

      gain = (lower_ranked.current_rank - higher_ranked.current_rank) / 2

      higher_ranked.lose_rank!
      lower_ranked.gain_rank!(gain)
    end

    def higher_ranked
      player_one.ranked_higher?(player_two) ? player_one : player_two
    end

    def lower_ranked
      player_one.ranked_lower?(player_two) ? player_one : player_two
    end

    def winner
      @_winner ||= result == "player_one" ? player_one : player_two
    end

    def loser
      @_loser ||= result == "player_one" ? player_two : player_one
    end
  end
end
