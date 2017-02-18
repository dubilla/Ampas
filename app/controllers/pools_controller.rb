class PoolsController < ApplicationController
  def show
    @pool = Pool.find(params[:id])
  end
end
