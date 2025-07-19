FactoryBot.define do
  factory :battle_unit do
    battle
    army
    unit
    health { 100 }
    morale { 100 }
    position_x { 1 }
    position_y { 1 }
    temp_attack_bonus { 0 }
    temp_defense_bonus { 0 }
    temp_morale_bonus { 0 }
    temp_movement_bonus { 0 }
    
    trait :damaged do
      health { 50 }
      morale { 75 }
    end
    
    trait :low_morale do
      morale { 30 }
    end
    
    trait :positioned do
      position_x { 5 }
      position_y { 5 }
    end
    
    trait :with_special_abilities do
      unit { create(:unit, special_abilities: ['charge', 'shield_wall']) }
    end
    
    trait :infantry do
      unit { create(:unit, unit_type: 'infantry') }
    end
    
    trait :cavalry do
      unit { create(:unit, unit_type: 'cavalry') }
    end
    
    trait :archer do
      unit { create(:unit, unit_type: 'archer') }
    end
  end
end