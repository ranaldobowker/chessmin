FactoryBot.define do
  factory :member do
    name                     { "Ada" }
    surname                  { "Lovelace" }
    sequence(:email_address) { |number| "member#{number}@example.com" }
    birthday                 { Date.new(1815, 12, 10) }
    club_games_played        { rand(0..100) }
  end
end