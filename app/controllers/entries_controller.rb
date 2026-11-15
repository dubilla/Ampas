class EntriesController < ApplicationController

  before_action :authenticate_user!

  def new
    @entry = pool.entries.build(
      {
        picks_attributes: @pool.categories.map{ |c| Pick.new(category_id: c.id) }.map(&:attributes),
        user: current_user
      }
    )
    authorize @entry
  end

  def edit
    authorize entry
    entry
  end

  def show
    authorize entry
    entry
  end

  def update
    authorize entry
    if entry.update(update_params)
      redirect_to entry
    else
      render 'edit', status: :unprocessable_content
    end
  end

  def create
    @entry = Entry.new(create_params)
    @entry.pool = pool
    @entry.user = current_user
    authorize @entry
    if @entry.save
      redirect_to @entry
    else
      render 'new', status: :unprocessable_content
    end
  rescue ActiveRecord::RecordNotUnique
    redirect_to pool_path(pool), alert: "Sorry, you can't do that.", status: :see_other
  end

  private

  def entry
    @entry ||= Entry.joins(pool: { award_ceremony: :categories }).includes(:picks).find(params[:id])
  end

  def pool
    @pool ||= Pool.find(params[:pool_id])
  end

  def create_params
    params.expect(entry: [picks_attributes: [[:nominee_id, :category_id]]])
  end

  def update_params
    params.expect(entry: [picks_attributes: [[:id, :nominee_id]]])
  end
end
