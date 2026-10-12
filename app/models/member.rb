class Member < ApplicationRecord
  validates :name,              presence: true
  validates :surname,           presence: true
  validates :email_address,     presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :birthday,          presence: true
  validates :club_games_played, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_create :set_current_rank

  def full_name
    "#{name} #{surname}"
  end

  def ranked_higher?(other_member)
    current_rank < other_member.current_rank
  end

  def ranked_lower?(other_member)
    current_rank > other_member.current_rank
  end

  def adjacent?(other_member)
    (current_rank - other_member.current_rank).abs == 1
  end

  private

  def set_current_rank
    self.current_rank = [ (Member.maximum(:current_rank).to_i + 1), 1 ].max
  end
end
