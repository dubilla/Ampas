class PoolsController < ApplicationController
  def index
    @pools = current_user.pools
  end
  def show
    @pool = Pool.find(params[:id])
  end
end
