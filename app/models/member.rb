class Member < ApplicationRecord
  validates :name,              presence: true
  validates :surname,           presence: true
  validates :email_address,     presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :birthday,          presence: true
  validates :club_games_played, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
