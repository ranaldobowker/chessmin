module Leaderboard
  class ValidateMatch
    VALID_RESULTS = %w[draw player_one player_two].freeze

    extend LightService::Action

    expects :player_one, :player_two, :result

    executed do |context|
      if context.player_one.id == context.player_two.id
        context.fail_and_return!("Players must be different")
      end

      unless VALID_RESULTS.include?(context.result)
        context.fail_and_return!("Invalid result: #{context.result}")
      end
    end
  end
end
