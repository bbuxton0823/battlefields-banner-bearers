class TerrainsController < ApplicationController
  def index
    @terrains = Terrain.all
  end

  def show
    @terrain = Terrain.find(params[:id])
  end
end
