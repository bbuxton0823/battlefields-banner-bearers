puts "🗡️ Seeding historical armies and terrains for Battlefields & Banner-Bearers..."

# Helper methods for calculating battlefield effects
def calculate_heat_penalty(terrain, army)
  base_penalty = terrain.heat_stress
  case army.name
  when "Soviet Ski Troops"
    base_penalty + 2 # Extra penalty for winter specialists in heat
  when "Mongol Horde"
    base_penalty - 1 # Less penalty for desert-adapted
  else
    base_penalty
  end
end

def calculate_mobility_penalty(terrain, army)
  base_penalty = terrain.mobility_modifier
  case army.name
  when "Mongol Horde"
    base_penalty + 1 # Less affected by terrain
  when "Roman Legion"
    base_penalty - 1 # Better at engineering solutions
  else
    base_penalty
  end
end

def calculate_visibility_penalty(terrain, army)
  base_penalty = 5 - terrain.visibility
  case army.name
  when "Aztec Eagle Warriors"
    base_penalty - 1 # Better in jungles
  when "English Longbowmen"
    base_penalty + 1 # Need clear sight lines
  else
    base_penalty
  end
end

def calculate_terrain_advantage(terrain, army)
  case [terrain.name, army.name]
  when ["Mojave Desert", "Mongol Horde"]
    2
  when ["Tibetan Mountains", "English Longbowmen"]
    2
  when ["Amazon Rainforest", "Aztec Eagle Warriors"]
    3
  when ["Siberian Tundra", "Soviet Ski Troops"]
    3
  when ["English Channel", "Viking Longship Raiders"]
    2
  else
    0
  end
end

# Clear existing data in correct order to avoid foreign key violations
puts "Clearing existing data..."
Battle.destroy_all
BattleUnit.destroy_all
Unit.destroy_all
Army.destroy_all
BattlefieldEffect.destroy_all
Terrain.destroy_all

# Create historical terrains
puts "Creating historical terrains..."
terrains = [
  {
    name: "Mojave Desert",
    terrain_type: "desert",
    climate: "arid",
    mobility_modifier: -2,
    heat_stress: 3,
    disease_risk: 1,
    visibility: 5,
    description: "Vast arid landscape with extreme temperature variations. Heavy armor suffers from heat exhaustion while light units excel.",
    historical_significance: "Site of Patton's WWII desert training and ancient trade routes"
  },
  {
    name: "Tibetan Mountains",
    terrain_type: "mountain",
    climate: "alpine",
    mobility_modifier: -3,
    heat_stress: 0,
    disease_risk: 2,
    visibility: 3,
    description: "High altitude terrain with thin air and treacherous passes. Ranged units gain advantage from elevation.",
    historical_significance: "Ancient Silk Road passes and WWII supply routes to China"
  },
  {
    name: "Amazon Rainforest",
    terrain_type: "jungle",
    climate: "tropical",
    mobility_modifier: -1,
    heat_stress: 2,
    disease_risk: 4,
    visibility: 2,
    description: "Dense vegetation and high humidity. Disease spreads rapidly but provides excellent cover for ambushes.",
    historical_significance: "Inca expansion routes and rubber boom conflicts"
  },
  {
    name: "Siberian Tundra",
    terrain_type: "tundra",
    climate: "subarctic",
    mobility_modifier: -2,
    heat_stress: 0,
    disease_risk: 1,
    visibility: 4,
    description: "Frozen wasteland with permafrost. Winter warfare specialists thrive while others struggle with cold.",
    historical_significance: "WWII Eastern Front battles and Mongol invasions"
  },
  {
    name: "English Channel",
    terrain_type: "coastal",
    climate: "maritime",
    mobility_modifier: 0,
    heat_stress: 1,
    disease_risk: 2,
    visibility: 3,
    description: "Treacherous waters with unpredictable weather. Naval units essential for crossing.",
    historical_significance: "Norman invasion of 1066 and WWII D-Day landings"
  },
  {
    name: "Gettysburg Battlefield",
    terrain_type: "mixed",
    climate: "temperate",
    mobility_modifier: -1,
    heat_stress: 1,
    disease_risk: 1,
    visibility: 4,
    description: "Rolling hills and ridges with strategic high ground positions. Mixed terrain favors combined arms tactics.",
    historical_significance: "Turning point of American Civil War in July 1863"
  },
  {
    name: "Waterloo Plains",
    terrain_type: "grassland",
    climate: "temperate",
    mobility_modifier: 0,
    heat_stress: 1,
    disease_risk: 1,
    visibility: 5,
    description: "Open plains with occasional ridges. Perfect for cavalry charges and artillery placement.",
    historical_significance: "Napoleon's final defeat in June 1815"
  },
  {
    name: "Thermopylae Pass",
    terrain_type: "mountain",
    climate: "mediterranean",
    mobility_modifier: -2,
    heat_stress: 2,
    disease_risk: 1,
    visibility: 3,
    description: "Narrow mountain pass that negates numerical advantages. Defensive position of legendary strength.",
    historical_significance: "300 Spartans held off Persian army in 480 BCE"
  },
  {
    name: "Hastings Ridge",
    terrain_type: "hill",
    climate: "temperate",
    mobility_modifier: -1,
    heat_stress: 1,
    disease_risk: 1,
    visibility: 4,
    description: "Elevated defensive position with commanding view. Uphill battles favor defenders.",
    historical_significance: "Norman conquest of England in 1066"
  },
  {
    name: "Cannae Plain",
    terrain_type: "grassland",
    climate: "mediterranean",
    mobility_modifier: 0,
    heat_stress: 2,
    disease_risk: 2,
    visibility: 5,
    description: "Flat plains ideal for maneuver warfare. Perfect for encirclement tactics.",
    historical_significance: "Hannibal's greatest victory against Rome in 216 BCE"
  }
]

terrains.each do |terrain_data|
  Terrain.create!(terrain_data)
end

# Create historical armies
puts "Creating historical armies..."
armies = [
  {
    name: "Sun Tzu's Warring States Army",
    era: "Ancient China (5th century BCE)",
    core_stat: "strategy",
    unique_weapon: "crossbow",
    signature_ability: "deception",
    factual_basis: "The Art of War emphasizes psychological warfare and strategic deception",
    historical_commander: "Sun Tzu",
    description: "Master tacticians who win through superior strategy rather than brute force"
  },
  {
    name: "Mongol Horde",
    era: "Medieval (13th century)",
    core_stat: "mobility",
    unique_weapon: "composite_bow",
    signature_ability: "feigned_retreat",
    factual_basis: "Mongols perfected mobile warfare and psychological terror tactics",
    historical_commander: "Genghis Khan",
    description: "Lightning-fast cavalry that strikes from unexpected directions"
  },
  {
    name: "Roman Legion",
    era: "Classical Rome (1st-2nd century CE)",
    core_stat: "discipline",
    unique_weapon: "gladius",
    signature_ability: "testudo",
    factual_basis: "Roman military engineering and tactical formations revolutionized warfare",
    historical_commander: "Julius Caesar",
    description: "Highly disciplined infantry with superior engineering and siege capabilities"
  },
  {
    name: "Viking Longship Raiders",
    era: "Viking Age (8th-11th century)",
    core_stat: "ferocity",
    unique_weapon: "battle_axe",
    signature_ability: "berserker_rage",
    factual_basis: "Viking raids combined naval mobility with shock infantry tactics",
    historical_commander: "Ragnar Lothbrok",
    description: "Fearsome warriors who strike from the sea with overwhelming force"
  },
  {
    name: "English Longbowmen",
    era: "Medieval England (14th-15th century)",
    core_stat: "range",
    unique_weapon: "longbow",
    signature_ability: "volley_fire",
    factual_basis: "English victories at Crecy and Agincourt demonstrated longbow superiority",
    historical_commander: "King Edward III",
    description: "Devastating ranged attacks that can decimate enemies before they close"
  },
  {
    name: "Ottoman Janissaries",
    era: "Ottoman Empire (14th-19th century)",
    core_stat: "firepower",
    unique_weapon: "musket",
    signature_ability: "disciplined_fire",
    factual_basis: "Elite infantry corps that combined firearms with traditional weapons",
    historical_commander: "Sultan Mehmed II",
    description: "Elite infantry combining gunpowder weapons with traditional combat skills"
  },
  {
    name: "Aztec Eagle Warriors",
    era: "Pre-Columbian Mesoamerica (14th-16th century)",
    core_stat: "agility",
    unique_weapon: "macuahuitl",
    signature_ability: "jaguar_strike",
    factual_basis: "Aztec military orders trained from youth in specialized combat techniques",
    historical_commander: "Moctezuma II",
    description: "Elite warriors trained from childhood in specialized combat techniques"
  },
  {
    name: "Soviet Ski Troops",
    era: "World War II (20th century)",
    core_stat: "winter_warfare",
    unique_weapon: "sniper_rifle",
    signature_ability: "white_death",
    factual_basis: "Finnish and Soviet ski troops excelled in winter warfare during WWII",
    historical_commander: "Simo Häyhä",
    description: "Specialized winter warfare units that turn snow and cold into weapons"
  },
  {
    name: "Spartan Phalanx",
    era: "Ancient Greece (5th century BCE)",
    core_stat: "discipline",
    unique_weapon: "dory_spear",
    signature_ability: "phalanx_formation",
    factual_basis: "Spartan military training created the most disciplined warriors of antiquity",
    historical_commander: "King Leonidas",
    description: "Unbreakable heavy infantry that fights to the last man"
  },
  {
    name: "Carthaginian Army",
    era: "Punic Wars (3rd-2nd century BCE)",
    core_stat: "versatility",
    unique_weapon: "falcata",
    signature_ability: "combined_arms",
    factual_basis: "Hannibal's army combined diverse units into an unstoppable force",
    historical_commander: "Hannibal Barca",
    description: "Multi-ethnic army that combines the best tactics from across the Mediterranean"
  },
  {
    name: "Norman Knights",
    era: "Medieval (11th century)",
    core_stat: "shock",
    unique_weapon: "lance",
    signature_ability: "cavalry_charge",
    factual_basis: "Norman cavalry dominated medieval battlefields across Europe",
    historical_commander: "William the Conqueror",
    description: "Heavy cavalry that breaks enemy lines with devastating charges"
  },
  {
    name: "Zulu Impi",
    era: "19th Century Africa",
    core_stat: "mobility",
    unique_weapon: "iklwa",
    signature_ability: "buffalo_horn",
    factual_basis: "Shaka Zulu revolutionized African warfare with the bull formation",
    historical_commander: "Shaka Zulu",
    description: "Fast-moving infantry that uses the buffalo horn encirclement tactic"
  }
]

armies.each do |army_data|
  army = Army.create!(army_data)
  
  # Create units for each army
  case army.name
  when "Sun Tzu's Warring States Army"
    Unit.create!([
      { army: army, name: "Strategist", unit_type: "commander", attack: 3, defense: 5, health: 100, morale: 9, movement: 4, special_ability: "tactical_advantage", description: "Master tactician who enhances nearby units" },
      { army: army, name: "Crossbowmen", unit_type: "ranged", attack: 7, defense: 3, health: 80, morale: 7, movement: 3, special_ability: "volley_fire", description: "Deadly accurate ranged units with high damage" },
      { army: army, name: "Spearmen", unit_type: "infantry", attack: 5, defense: 6, health: 90, morale: 8, movement: 3, special_ability: "phalanx", description: "Defensive infantry that excels in formation" }
    ])
  when "Mongol Horde"
    Unit.create!([
      { army: army, name: "Khan", unit_type: "commander", attack: 4, defense: 4, health: 100, morale: 10, movement: 6, special_ability: "inspiring_charge", description: "Legendary leader who inspires fear and loyalty" },
      { army: army, name: "Horse Archers", unit_type: "cavalry", attack: 6, defense: 4, health: 85, morale: 8, movement: 8, special_ability: "hit_and_run", description: "Mobile archers who strike and retreat" },
      { army: army, name: "Heavy Cavalry", unit_type: "cavalry", attack: 8, defense: 5, health: 95, morale: 9, movement: 6, special_ability: "shock_charge", description: "Devastating cavalry charge that breaks enemy lines" }
    ])
  when "Roman Legion"
    Unit.create!([
      { army: army, name: "Legate", unit_type: "commander", attack: 3, defense: 6, health: 100, morale: 9, movement: 3, special_ability: "discipline", description: "Roman commander who maintains unit cohesion" },
      { army: army, name: "Legionaries", unit_type: "infantry", attack: 6, defense: 7, health: 95, morale: 8, movement: 3, special_ability: "testudo", description: "Disciplined heavy infantry with superior defense" },
      { army: army, name: "Ballista", unit_type: "siege", attack: 9, defense: 2, health: 70, morale: 6, movement: 1, special_ability: "siege_attack", description: "Powerful siege weapon that devastates fortifications" }
    ])
  when "Viking Longship Raiders"
    Unit.create!([
      { army: army, name: "Jarl", unit_type: "commander", attack: 5, defense: 4, health: 100, morale: 9, movement: 4, special_ability: "berserker_rage", description: "Fearless leader who inspires berserker fury" },
      { army: army, name: "Berserkers", unit_type: "infantry", attack: 9, defense: 3, health: 90, morale: 10, movement: 4, special_ability: "frenzy", description: "Warriors who fight with supernatural fury" },
      { army: army, name: "Shield Maidens", unit_type: "infantry", attack: 6, defense: 6, health: 85, morale: 8, movement: 4, special_ability: "shield_wall", description: "Elite female warriors with exceptional defense" }
    ])
  when "English Longbowmen"
    Unit.create!([
      { army: army, name: "Captain", unit_type: "commander", attack: 3, defense: 5, health: 100, morale: 8, movement: 3, special_ability: "volley_command", description: "Skilled commander who coordinates devastating volleys" },
      { army: army, name: "Longbowmen", unit_type: "ranged", attack: 8, defense: 2, health: 75, morale: 7, movement: 3, special_ability: "piercing_shot", description: "Devastating long-range archers with armor-piercing arrows" },
      { army: army, name: "Men-at-Arms", unit_type: "infantry", attack: 5, defense: 5, health: 90, morale: 7, movement: 3, special_ability: "defensive_stance", description: "Professional soldiers who protect the archers" }
    ])
  when "Ottoman Janissaries"
    Unit.create!([
      { army: army, name: "Agha", unit_type: "commander", attack: 4, defense: 5, health: 100, morale: 9, movement: 3, special_ability: "disciplined_fire", description: "Elite commander who coordinates precise volleys" },
      { army: army, name: "Janissaries", unit_type: "infantry", attack: 7, defense: 5, health: 85, morale: 9, movement: 3, special_ability: "musket_volley", description: "Elite infantry with superior firearms training" },
      { army: army, name: "Artillery", unit_type: "siege", attack: 10, defense: 1, health: 60, morale: 6, movement: 1, special_ability: "cannon_fire", description: "Powerful artillery that can destroy any fortification" }
    ])
  when "Aztec Eagle Warriors"
    Unit.create!([
      { army: army, name: "Eagle Knight", unit_type: "commander", attack: 5, defense: 4, health: 100, morale: 9, movement: 5, special_ability: "jaguar_strike", description: "Elite warrior who leads with supernatural agility" },
      { army: army, name: "Eagle Warriors", unit_type: "infantry", attack: 7, defense: 4, health: 80, morale: 8, movement: 5, special_ability: "ambush", description: "Elite warriors trained in stealth and surprise attacks" },
      { army: army, name: "Jaguar Warriors", unit_type: "infantry", attack: 8, defense: 3, health: 85, morale: 9, movement: 4, special_ability: "ferocity", description: "Fearsome warriors who fight with animal-like ferocity" }
    ])
  when "Soviet Ski Troops"
    Unit.create!([
      { army: army, name: "Sniper", unit_type: "ranged", attack: 9, defense: 2, health: 70, morale: 8, movement: 5, special_ability: "white_death", description: "Legendary sniper who can eliminate key targets" },
      { army: army, name: "Ski Troops", unit_type: "infantry", attack: 6, defense: 4, health: 80, morale: 8, movement: 7, special_ability: "winter_mobility", description: "Specialized troops who excel in winter conditions" },
      { army: army, name: "Partisans", unit_type: "infantry", attack: 5, defense: 3, health: 75, morale: 9, movement: 6, special_ability: "guerrilla_warfare", description: "Irregular fighters who use hit-and-run tactics" }
    ])
  when "Spartan Phalanx"
    Unit.create!([
      { army: army, name: "Spartan King", unit_type: "commander", attack: 4, defense: 6, health: 100, morale: 10, movement: 3, special_ability: "stand_firm", description: "Unyielding commander who never retreats" },
      { army: army, name: "Spartan Hoplites", unit_type: "infantry", attack: 6, defense: 8, health: 95, morale: 10, movement: 2, special_ability: "phalanx_formation", description: "Unbreakable heavy infantry with massive shields" },
      { army: army, name: "Helot Skirmishers", unit_type: "infantry", attack: 4, defense: 3, health: 70, morale: 6, movement: 4, special_ability: "harassment", description: "Light infantry that supports the phalanx" }
    ])
  when "Carthaginian Army"
    Unit.create!([
      { army: army, name: "Hannibal", unit_type: "commander", attack: 5, defense: 5, health: 100, morale: 9, movement: 4, special_ability: "tactical_genius", description: "History's greatest tactician who outmaneuvered Rome" },
      { army: army, name: "Numidian Cavalry", unit_type: "cavalry", attack: 7, defense: 4, health: 80, morale: 8, movement: 8, special_ability: "hit_and_run", description: "Lightning-fast cavalry from North Africa" },
      { army: army, name: "Gallic Warriors", unit_type: "infantry", attack: 8, defense: 3, health: 85, morale: 7, movement: 4, special_ability: "feral_charge", description: "Fierce warriors who fight with wild abandon" },
      { army: army, name: "War Elephants", unit_type: "cavalry", attack: 10, defense: 6, health: 120, morale: 8, movement: 3, special_ability: "trample", description: "Terrifying beasts that crush enemy formations" }
    ])
  when "Norman Knights"
    Unit.create!([
      { army: army, name: "Duke William", unit_type: "commander", attack: 5, defense: 5, health: 100, morale: 9, movement: 5, special_ability: "inspiring_leadership", description: "Conqueror who united Normandy and England" },
      { army: army, name: "Norman Knights", unit_type: "cavalry", attack: 9, defense: 6, health: 95, morale: 8, movement: 6, special_ability: "cavalry_charge", description: "Heavy cavalry that breaks enemy lines" },
      { army: army, name: "Breton Archers", unit_type: "ranged", attack: 6, defense: 2, health: 70, morale: 7, movement: 4, special_ability: "suppressive_fire", description: "Skilled archers who provide covering fire" }
    ])
  when "Zulu Impi"
    Unit.create!([
      { army: army, name: "Shaka Zulu", unit_type: "commander", attack: 5, defense: 4, health: 100, morale: 10, movement: 5, special_ability: "buffalo_horn", description: "Revolutionary commander who transformed African warfare" },
      { army: army, name: "Zulu Warriors", unit_type: "infantry", attack: 7, defense: 4, health: 85, morale: 9, movement: 5, special_ability: "buffalo_formation", description: "Disciplined warriors using the buffalo horn tactic" },
      { army: army, name: "Zulu Skirmishers", unit_type: "infantry", attack: 5, defense: 3, health: 75, morale: 8, movement: 6, special_ability: "encirclement", description: "Fast-moving units that flank the enemy" }
    ])
  end
end

# Create battlefield effects for each terrain-army combination
puts "Creating battlefield effects..."
Terrain.all.each do |terrain|
  Army.all.each do |army|
    BattlefieldEffect.create!(
      terrain: terrain,
      army: army,
      heat_penalty: calculate_heat_penalty(terrain, army),
      mobility_penalty: calculate_mobility_penalty(terrain, army),
      visibility_penalty: calculate_visibility_penalty(terrain, army),
      disease_risk: terrain.disease_risk,
      morale_modifier: calculate_terrain_advantage(terrain, army)
    )
  end
end

# Create historical battles with educational content
puts "Creating historical battles..."

# Battle of Thermopylae
thermopylae = Battle.create!(
  name: "Battle of Thermopylae",
  description: "King Leonidas and 300 Spartans make their legendary last stand against Xerxes' massive Persian army in the narrow mountain pass of Thermopylae.",
  historical_context: "In 480 BCE, during the second Persian invasion of Greece, King Leonidas led a small Greek force to delay the Persian advance. The narrow pass at Thermopylae negated the Persians' numerical advantage, allowing the Greeks to hold for three days.",
  learning_objective: "Understand how terrain can negate numerical advantages in warfare, and the concept of a tactical delaying action.",
  terrain: Terrain.find_by(name: "Thermopylae Pass"),
  max_turns: 10,
  victory_condition: "annihilation",
  status: "pending"
)

# Battle of Cannae
cannae = Battle.create!(
  name: "Battle of Cannae",
  description: "Hannibal executes the perfect double envelopment, surrounding and destroying a much larger Roman army in one of history's greatest tactical masterpieces.",
  historical_context: "In 216 BCE, during the Second Punic War, Hannibal Barca used superior tactics to encircle and destroy a Roman force twice the size of his own army. This battle is studied in military academies to this day.",
  learning_objective: "Master the concept of encirclement tactics and how superior generalship can overcome numerical disadvantages.",
  terrain: Terrain.find_by(name: "Cannae Plain"),
  max_turns: 12,
  victory_condition: "annihilation",
  status: "pending"
)

# Battle of Hastings
hastings = Battle.create!(
  name: "Battle of Hastings",
  description: "William the Conqueror's Norman knights face King Harold's Saxon shield wall in the battle that changed English history forever.",
  historical_context: "On October 14, 1066, William, Duke of Normandy defeated King Harold II of England. This battle marked the end of Anglo-Saxon rule and the beginning of Norman England, fundamentally changing English culture and language.",
  learning_objective: "Examine how combined arms tactics (cavalry, infantry, and archers) can overcome a strong defensive position.",
  terrain: Terrain.find_by(name: "Hastings Ridge"),
  max_turns: 15,
  victory_condition: "annihilation",
  status: "pending"
)

# Battle of Waterloo
waterloo = Battle.create!(
  name: "Battle of Waterloo",
  description: "Napoleon's final defeat as Wellington and Blücher combine to end the Napoleonic Wars and exile Napoleon to St. Helena.",
  historical_context: "On June 18, 1815, Napoleon Bonaparte was defeated by the Seventh Coalition, led by the Duke of Wellington and Gebhard Leberecht von Blücher. This battle ended the Napoleonic Wars and led to nearly a century of relative peace in Europe.",
  learning_objective: "Analyze the importance of coalition warfare and how holding key terrain can lead to decisive victory.",
  terrain: Terrain.find_by(name: "Waterloo Plains"),
  max_turns: 20,
  victory_condition: "annihilation",
  status: "pending"
)

# Battle of Gettysburg
gettysburg = Battle.create!(
  name: "Battle of Gettysburg",
  description: "The turning point of the American Civil War, where Pickett's Charge fails and Lee's invasion of the North is repelled.",
  historical_context: "From July 1-3, 1863, the largest number of casualties of the entire American Civil War occurred at Gettysburg. General Lee's defeat ended his invasion of the North and is considered the turning point of the war.",
  learning_objective: "Understand the strategic importance of high ground and how attacking uphill against prepared positions is extremely costly.",
  terrain: Terrain.find_by(name: "Gettysburg Battlefield"),
  max_turns: 18,
  victory_condition: "annihilation",
  status: "pending"
)

# Battle of Zama
zama = Battle.create!(
  name: "Battle of Zama",
  description: "Scipio Africanus defeats Hannibal in the final battle of the Second Punic War, establishing Rome as the dominant Mediterranean power.",
  historical_context: "In 202 BCE, Scipio Africanus defeated Hannibal Barca, ending the Second Punic War. This battle marked the rise of Rome as the dominant power in the western Mediterranean and the beginning of Carthage's decline.",
  learning_objective: "Study how adapting tactics to counter specific enemy strengths can lead to decisive victory.",
  terrain: Terrain.find_by(name: "Cannae Plain"),
  max_turns: 14,
  victory_condition: "annihilation",
  status: "pending"
)

# Battle of Agincourt
agincourt = Battle.create!(
  name: "Battle of Agincourt",
  description: "Henry V's outnumbered English army devastates the French nobility with the longbow, proving the dominance of ranged weapons.",
  historical_context: "On October 25, 1415, during the Hundred Years' War, King Henry V of England defeated a much larger French army. The English longbowmen proved the effectiveness of ranged weapons against heavy cavalry.",
  learning_objective: "Demonstrate how technological advantages (the longbow) and terrain can overcome massive numerical disadvantages.",
  terrain: Terrain.find_by(name: "Waterloo Plains"),
  max_turns: 8,
  victory_condition: "annihilation",
  status: "pending"
)

# Battle of Marathon
marathon = Battle.create!(
  name: "Battle of Marathon",
  description: "The first great victory of Western civilization, where Athenian hoplites charge across the plain to defeat the Persian invasion.",
  historical_context: "In 490 BCE, the Athenians and Plataeans defeated the first Persian invasion of Greece. This victory preserved Greek independence and allowed the development of Western civilization as we know it.",
  learning_objective: "Understand the concept of the decisive battle and how a single day's fighting can change the course of history.",
  terrain: Terrain.find_by(name: "Cannae Plain"),
  max_turns: 6,
  victory_condition: "annihilation",
  status: "pending"
)

# Battle of Tours
tours = Battle.create!(
  name: "Battle of Tours",
  description: "Charles Martel's Frankish army halts the Islamic expansion into Western Europe, preserving Christianity in the West.",
  historical_context: "In 732 CE, Charles Martel defeated the Umayyad Caliphate's army, halting the advance of Islam into Western Europe. This battle is considered one of the most important in world history.",
  learning_objective: "Examine how defensive tactics and terrain can be used to counter superior cavalry forces.",
  terrain: Terrain.find_by(name: "Hastings Ridge"),
  max_turns: 12,
  victory_condition: "annihilation",
  status: "pending"
)

# Battle of Alesia
alesia = Battle.create!(
  name: "Siege of Alesia",
  description: "Julius Caesar's masterpiece of siege warfare, where he builds a double wall to besiege Vercingetorix while defending against relief armies.",
  historical_context: "In 52 BCE, Julius Caesar completed the conquest of Gaul by besieging Vercingetorix at Alesia. Caesar built a double wall - one to besiege the city, another to defend against relief armies.",
  learning_objective: "Master the concept of siege warfare and how engineering can overcome numerical disadvantages.",
  terrain: Terrain.find_by(name: "Gettysburg Battlefield"),
  max_turns: 25,
  victory_condition: "annihilation",
  status: "pending"
)

puts "✅ Historical data seeded successfully!"
puts "Created #{Army.count} armies, #{Unit.count} units, #{Terrain.count} terrains, #{Battle.count} historical battles, and #{BattlefieldEffect.count} battlefield effects"
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?