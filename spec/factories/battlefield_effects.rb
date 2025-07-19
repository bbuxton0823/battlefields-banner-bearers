FactoryBot.define do
  factory :battlefield_effect do
    association :terrain
    association :army
    heat_penalty { 2 }
    mobility_penalty { 1 }
    visibility_penalty { 0 }
    disease_risk { 1 }
    morale_modifier { -1 }
    description { "Roman legions suffer reduced effectiveness in desert conditions due to heavy armor and heat exhaustion." }
  end
end
