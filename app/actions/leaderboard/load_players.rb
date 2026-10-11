module Leaderboard
  class LoadPlayers
    extend LightService::Action

    expects  :player_one_id, :player_two_id
    promises :player_one, :player_two

    executed do |context|
      player_one = Member.find_by(id: context.player_one_id)
      context.fail_and_return!("Player one not found") unless player_one

      player_two = Member.find_by(id: context.player_two_id)
      context.fail_and_return!("Player two not found") unless player_two

      context.player_one = player_one
      context.player_two = player_two
    end
  end
end
