class EnergyController < ApplicationController
  include EnergyHelper

  before_filter :authenticate_user!
    
  # GET /energy/update_energy
  def update_energy
      check_energy!
      render :json => {}
  end
end
