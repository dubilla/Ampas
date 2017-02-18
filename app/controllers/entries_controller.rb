class EntriesController < ApplicationController

  before_action :authenticate_user!

  def new
    @entry = pool.entries.build(
      {
        picks_attributes: @pool.categories.map{ |c| Pick.new(category_id: c.id) }.map(&:attributes),
        user: current_user
      }
    )
  end

  def edit
    authorize entry
    entry
  end

  def show
    entry
  end

  def update
    @entry = Entry.find(params[:id])
    if @entry.update_attributes(entry_params)
      redirect_to @entry
    else
      render 'edit'
    end
  end

  private

  def entry
    @entry ||= Entry.joins(pool: { award_ceremony: :categories }).includes(:picks).find(params[:id])
  end

  def pool
    @pool ||= Pool.find(params[:pool_id])
  end

  def entry_params
    params
      .required(:entry)
      .permit(picks_attributes: [:id, :nominee_id, :category_id])
  end
end
