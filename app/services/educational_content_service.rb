require 'ostruct'

class EducationalContentService
  def self.generate_contextual_content(terrain, army)
    {
      title: "#{army.name} in #{terrain.name}",
      content: generate_content_html(terrain, army),
      historical_fact: generate_historical_fact(terrain, army),
      learning_objective: generate_learning_objective(terrain, army)
    }
  end

  def self.generate_battle_summary(battle)
    # Get armies from battle units
    armies = battle.units.includes(:army).map(&:army).uniq
    army1 = armies.first
    army2 = armies.second
    
    {
      title: "Battle Summary: #{army1&.name} vs #{army2&.name}",
      summary: generate_summary_html(battle, army1, army2),
      key_learning: generate_key_learning(battle, army1, army2)
    }
  end

  def self.get_unlockable_content(criteria)
    unlockables = {
      "first_victory" => {
        title: "First Victory Unlocked!",
        description: "Congratulations on your first victory! You've learned the basics of historical warfare.",
        historical_context: "Throughout history, first victories often came with valuable lessons about terrain, tactics, and the importance of understanding your enemy."
      },
      "terrain_master" => {
        title: "Terrain Master",
        description: "You've successfully used terrain to your advantage in multiple battles.",
        historical_context: "Great commanders like Hannibal and Napoleon understood that terrain could be as important as troop numbers in determining battle outcomes."
      },
      "army_specialist" => {
        title: "Army Specialist",
        description: "You've mastered the unique characteristics of a historical army.",
        historical_context: "Each army throughout history developed unique tactics and weapons suited to their culture, geography, and available resources."
      }
    }
    
    unlockables[criteria]
  end

  private

  def self.generate_content_html(terrain, army)
    <<~HTML
      <div class="space-y-4">
        <h4 class="font-semibold">Historical Setting</h4>
        <p>#{army.name} (#{army.era}) operating in #{terrain.name} terrain.</p>
        
        <h4 class="font-semibold">#{army.name} Characteristics</h4>
        <ul class="list-disc list-inside">
          <li>#{army.core_stat} as primary advantage</li>
          <li>#{army.unique_weapon} as signature weapon</li>
          <li>#{army.signature_ability} as tactical approach</li>
        </ul>
        
        <h4 class="font-semibold">Terrain Impact</h4>
        <p>#{terrain.description}</p>
        <p>#{terrain.historical_significance}</p>
        <p>Climate: #{terrain.climate}</p>
      </div>
    HTML
  end

  def self.generate_historical_fact(terrain, army)
    "Historical fact: #{army.factual_basis} This combination of #{army.name} and #{terrain.name} represents a unique moment in military history where #{army.historical_commander} had to adapt tactics to challenging environmental conditions."
  end

  def self.generate_learning_objective(terrain, army)
    "Understand how #{army.name} adapted their tactics and equipment to operate effectively in #{terrain.terrain_type} terrain with #{terrain.climate} conditions."
  end

  def self.generate_summary_html(battle, army1, army2)
    <<~HTML
      <div class="space-y-4">
        <h4 class="font-semibold">Battle Overview</h4>
        <p>#{army1&.name} faced #{army2&.name} in the challenging terrain of #{battle.terrain.name}.</p>
        
        <h4 class="font-semibold">Terrain Analysis</h4>
        <p>The #{battle.terrain.name} provided unique challenges including #{battle.terrain.description.downcase}.</p>
        
        <h4 class="font-semibold">Historical Context</h4>
        <p>This battle simulation reflects real historical conditions where armies had to adapt to environmental factors.</p>
      </div>
    HTML
  end

  def self.generate_key_learning(battle, army1, army2)
    "Key learning: Understanding how different armies perform in various terrains is crucial for historical analysis and strategic thinking."
  end
end