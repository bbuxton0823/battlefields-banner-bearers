FactoryBot.define do
  factory :army do
    name { "Roman Legions" }
    era { "27 BC - 476 AD" }
    core_stat { "Discipline" }
    unique_weapon { "Gladius" }
    signature_ability { "Testudo Formation" }
    factual_basis { "Professional heavy infantry with standardized equipment and rigorous training" }
    historical_commander { "Julius Caesar" }
    description { "The backbone of Roman military power, these professional soldiers were renowned for their discipline, tactical flexibility, and engineering prowess." }
  end
end
