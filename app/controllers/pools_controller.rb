class PoolsController < ApplicationController
  def index
    if current_user.present?
      @pools = current_user.pools
    else
      redirect_to root_path
    end
  end
  def show
    @pool = Pool.find(params[:id])
  end
end
