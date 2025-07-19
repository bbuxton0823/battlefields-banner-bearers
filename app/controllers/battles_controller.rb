class BattlesController < ApplicationController
  before_action :set_battle, only: [:show, :play, :resolve_turn, :educational_content, :perform_action, :replay, :statistics]

  def index
    @battles = Battle.all
  end

  def new
    @battle = Battle.new
    @armies = Army.all
    @terrains = Terrain.all
  end

  def create
    @battle = Battle.new(battle_params)
    @battle.status = 'setup'
    @battle.current_turn = 1
    
    if @battle.save
      redirect_to play_battle_path(@battle), notice: 'Battle created successfully!'
    else
      @armies = Army.all
      @terrains = Terrain.all
      render :new
    end
  end

  def show
    @attacking_army = @battle.attacking_army
    @defending_army = @battle.defending_army
    @terrain = @battle.terrain
    
    # Get units for each army
    @attacking_units = @attacking_army.units
    @defending_units = @defending_army.units
    
    # Calculate battlefield effects
    @effects = BattlefieldEffect.find_or_create_by(
      terrain: @terrain,
      attacking_army: @attacking_army,
      defending_army: @defending_army
    )
  end

  def play
    @attacking_army = @battle.attacking_army
    @defending_army = @battle.defending_army
    @terrain = @battle.terrain
    
    # Get active units
    @attacking_units = @battle.attacking_army.units.where('health > 0')
    @defending_units = @battle.defending_army.units.where('health > 0')
    
    # Calculate battlefield effects
    @effects = BattlefieldEffect.find_or_create_by(
      terrain: @terrain,
      attacking_army: @attacking_army,
      defending_army: @defending_army
    )
    
    # Generate educational briefing
    @educational_briefing = EducationalContentService.generate_pre_battle_content(
      @attacking_army,
      @defending_army,
      @terrain
    )
  end

  def resolve_turn
    @attacking_army = @battle.attacking_army
    @defending_army = @battle.defending_army
    
    # Get active units
    attacking_units = @battle.attacking_army.units.where('health > 0')
    defending_units = @battle.defending_army.units.where('health > 0')
    
    # Resolve the turn
    resolver = TurnResolver.new(@battle, attacking_units + defending_units)
    result = resolver.resolve_turn
    
    # Store educational content in session
    session[:educational_content] = result[:educational_content]
    
    # Set instance variables for turbo stream
    @educational_content = result[:educational_content]
    @victory_result = result[:victory_result]
    
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to play_battle_path(@battle) }
    end
  end

  def educational_content
    @content = session[:educational_content] || []
    
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("educational_modal",
          partial: "battles/educational_modal",
          locals: { content: @content }
        )
      end
    end
  end

  def perform_action
    action = params[:action_type]
    unit_id = params[:unit_id]
    target_id = params[:target_id]

    # Find the battle unit
    battle_unit = @battle.battle_units.find_by(unit_id: unit_id)
    
    if battle_unit
      # Perform the action based on type
      result = case action
      when 'attack'
        perform_attack(battle_unit, target_id)
      when 'defend'
        perform_defend(battle_unit)
      when 'retreat'
        perform_retreat(battle_unit)
      else
        { success: false, error: "Invalid action" }
      end
      
      render json: result
    else
      render json: { success: false, error: "Unit not found" }
    end
  end

  def replay
    @replay_data = BattleReplayService.new(@battle).generate_replay
    @battle_events = @battle.battle_replays.order(:turn_number, :event_order)
    
    respond_to do |format|
      format.html
      format.json { render json: @replay_data }
    end
  end

  def statistics
    @attacking_army = @battle.attacking_army
    @defending_army = @battle.defending_army
    @terrain = @battle.terrain
    
    @statistics = BattleStatisticsService.new(@battle).generate_statistics
    
    respond_to do |format|
      format.html
      format.json { render json: @statistics }
    end
  end

  private

  def perform_attack(attacker, target_id)
    target = @battle.battle_units.find_by(unit_id: target_id)
    
    if target
      damage = calculate_damage(attacker, target)
      target.current_health = [target.current_health - damage, 0].max
      
      if target.save
        {
          success: true,
          damage: damage,
          target_health: target.current_health,
          target_morale: target.current_morale
        }
      else
        { success: false, error: "Failed to update target" }
      end
    else
      { success: false, error: "Target not found" }
    end
  end

  def perform_defend(unit)
    unit.defense_modifier = (unit.defense_modifier || 1) * 1.5
    if unit.save
      { success: true, defense_modifier: unit.defense_modifier }
    else
      { success: false, error: "Failed to update unit" }
    end
  end

  def perform_retreat(unit)
    unit.has_retreated = true
    if unit.save
      { success: true, retreated: true }
    else
      { success: false, error: "Failed to retreat unit" }
    end
  end

  def calculate_damage(attacker, target)
    base_damage = attacker.unit.attack
    defense = target.unit.defense * (target.defense_modifier || 1)
    
    # Simple damage calculation
    damage = [base_damage - defense, 1].max
    
    # Add some randomness
    damage = (damage * (0.8 + rand * 0.4)).round
    
    damage
  end

  private

  def set_battle
    @battle = Battle.find(params[:id])
  end

  def battle_params
    params.require(:battle).permit(:name, :terrain_id, :max_turns, :attacking_army_id, :defending_army_id, :victory_conditions)
  end

  def generate_educational_briefing
    {
      historical_context: {
        title: "Historical Context",
        content: "This battle simulates #{@battle.attacking_army.name} versus #{@battle.defending_army.name} in #{@battle.terrain.name}. #{@battle.terrain.historical_significance}"
      },
      army_strengths: {
        attacking: {
          name: @battle.attacking_army.name,
          strength: @battle.attacking_army.core_stat,
          weapon: @battle.attacking_army.unique_weapon,
          ability: @battle.attacking_army.signature_ability,
          fact: @battle.attacking_army.factual_basis
        },
        defending: {
          name: @battle.defending_army.name,
          strength: @battle.defending_army.core_stat,
          weapon: @battle.defending_army.unique_weapon,
          ability: @battle.defending_army.signature_ability,
          fact: @battle.defending_army.factual_basis
        }
      },
      terrain_effects: {
        name: @battle.terrain.name,
        description: @battle.terrain.description,
        climate: @battle.terrain.climate,
        effects: {
          mobility: @battle.terrain.mobility_modifier,
          heat_stress: @battle.terrain.heat_stress,
          disease_risk: @battle.terrain.disease_risk,
          visibility: @battle.terrain.visibility
        }
      }
    }
  end
end