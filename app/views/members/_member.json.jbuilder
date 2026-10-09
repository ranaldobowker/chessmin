json.extract! member, :id, :name, :surname, :email_address, :birthday, :club_games_played, :current_rank, :created_at, :updated_at
json.url member_url(member, format: :json)
