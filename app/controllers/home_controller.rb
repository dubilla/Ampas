class HomeController < ApplicationController
  def index
    if current_user && current_user.pools.exists?
      redirect_to pools_path
    end
  end
end
