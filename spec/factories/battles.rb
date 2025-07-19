FactoryBot.define do
  factory :battle do
    name { "Battle of the Mojave" }
    status { "setup" }
    current_turn { 0 }
    max_turns { 10 }
    victory_conditions { "Destroy all enemy units or hold the strategic position for 5 turns" }
    educational_unlocks { "Understanding of desert warfare tactics and Roman engineering" }
    association :terrain
  end
end
