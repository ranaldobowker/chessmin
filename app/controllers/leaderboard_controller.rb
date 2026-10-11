class LeaderboardController < ApplicationController
  before_action :set_active_nav, only: [ :index, :enter_match ]

  def index
    @members = Member.order(:current_rank)
  end

  def enter_match
    @members = Member.order(:name, :surname)
  end

  def submit_match
    result = ::Leaderboard::RecordMatch.call(**match_params)

    unless result.success?
      redirect_to leaderboard_enter_match_path, alert: result.message
      return
    end

    redirect_to leaderboard_index_path, notice: "Match submitted."
  end

  private

  def set_active_nav
    @nav = :leaderboard
  end

  def match_params
    params.permit(:player_one_id, :player_two_id, :result).to_h.symbolize_keys
  end
end
