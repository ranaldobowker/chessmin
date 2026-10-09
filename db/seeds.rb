# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

members = [
  ["Amelia",   "Hart",     "amelia.hart@example.com",   Date.new(1992, 3, 14),  24],
  ["Benjamin", "Cole",     "benjamin.cole@example.com", Date.new(1988, 7, 22),  31],
  ["Julian",   "Brooks",   "julian.brooks@example.com", Date.new(1987, 10, 8),  38],
  ["Leo",      "Carter",   "leo.carter@example.com",    Date.new(1996, 8, 27),  15],
  ["Maya",     "Ellis",    "maya.ellis@example.com",    Date.new(1989, 1, 12),  47],
  ["Nathan",   "Ward",     "nathan.ward@example.com",   Date.new(1984, 3, 21),  63],
  ["Peter",    "Lawson",   "peter.lawson@example.com",  Date.new(1986, 11, 19), 51],
  ["Quinn",    "Fisher",   "quinn.fisher@example.com",  Date.new(1999, 5, 2),   7],
  ["Ruby",     "Sullivan", "ruby.sullivan@example.com", Date.new(1992, 9, 24),  26],
  ["Tessa",    "Murray",   "tessa.murray@example.com",  Date.new(1995, 12, 28), 19]
]

members.each do |name, surname, email_address, birthday, club_games_played|
  Member.find_or_create_by!(email_address: email_address) do |member|
    member.assign_attributes(
    name: name,
    surname: surname,
    birthday: birthday,
     club_games_played: club_games_played
    )

    puts "Created or found member: #{member.email_address}"
  end
end