module Leaderboard
  class RebalanceRanks
    extend LightService::Action

    expects :rank_changes

    executed do |ctx|
      next ctx if ctx.rank_changes.empty?

      members_by_id = Member.order(:current_rank, :id).index_by(&:id)
      leaderboard   = Array.new(members_by_id.size)

      ctx.rank_changes.each do |member_id, target_rank|
        leaderboard[target_rank - 1] = members_by_id.fetch(member_id)
        members_by_id.delete(member_id)
      end

      remaining_members = members_by_id.values
      leaderboard.map! { |member| member || remaining_members.shift }

      leaderboard.each.with_index(1) do |member, rank|
        member.update!(current_rank: rank) unless member.current_rank == rank
      end
    end
  end
end
