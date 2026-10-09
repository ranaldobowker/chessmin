class LeaderboardController < ApplicationController
  before_action :set_active_nav, only: [ :index, :enter_match ]

  def index
    @members = Member.order(:current_rank)
  end

  def enter_match
    @members = Member.order(:name, :surname)
  end

  def submit_match
    redirect_to leaderboard_index_path, notice: "Match submitted."
  end

  private

  def set_active_nav
    @nav = :leaderboard
  end
end
