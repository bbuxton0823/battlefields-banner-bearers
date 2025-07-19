FactoryBot.define do
  factory :terrain do
    name { "Mojave Desert" }
    terrain_type { "Desert" }
    climate { "Hot and Arid" }
    mobility_modifier { -2 }
    heat_stress { 5 }
    cold_stress { 0 }
    disease_risk { 2 }
    visibility { 8 }
    description { "A harsh desert environment with extreme temperatures and limited water sources." }
    historical_significance { "Site of Native American trade routes and later military training grounds." }
  end
end
