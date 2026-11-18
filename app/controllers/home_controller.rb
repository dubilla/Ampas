class HomeController < ApplicationController
  def index
    return unless current_user && current_user.pools.exists?

    redirect_to pools_path
  end
end
