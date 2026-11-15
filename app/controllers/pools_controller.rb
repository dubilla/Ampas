class PoolsController < ApplicationController
  def index
    if current_user.present?
      @pools = current_user.pools.includes(:award_ceremony)
    else
      redirect_to root_path
    end
  end
  def show
    @pool = Pool.find(params[:id])
    @entries = @pool.entries.includes(:user, picks: :nominee)
  end
end
