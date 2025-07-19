FactoryBot.define do
  factory :unit do
    association :army
    name { "Legionary" }
    unit_type { "infantry" }
    attack { 8 }
    defense { 6 }
    health { 10 }
    morale { 8 }
    movement { 3 }
    special_ability { "Shield Wall" }
    description { "The backbone of Roman military might, these heavily armored infantry formed the famous testudo formation." }
  end
end
