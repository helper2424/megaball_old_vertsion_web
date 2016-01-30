class FbAuthController < ApplicationController
  def index
    @current_provider = params[:current_provider] || 'fb'
    @id = MEGABALL_IFRAME_CONFIG[@current_provider]['id']
  end
end
