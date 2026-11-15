class EntriesController < ApplicationController

  before_action :authenticate_user!

  def new
    @entry = pool.entries.build(user: current_user)
    authorize @entry
    @picks = picks_for_form
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
      @picks = picks_for_form
      render 'new', status: :unprocessable_content
    end
  rescue ActiveRecord::RecordNotUnique
    redirect_to pool_path(pool), alert: "Sorry, you can't do that.", status: :see_other
  end

  private

  def entry
    @entry ||= Entry.includes(:user, pool: :award_ceremony, picks: [:nominee, { category: :nominees }]).find(params[:id])
  end

  def pool
    @pool ||= Pool.find(params[:pool_id])
  end

  def picks_for_form
    submitted = @entry.picks.index_by(&:category_id)
    pool.categories.includes(:nominees).map do |category|
      pick = submitted[category.id] || @entry.picks.build
      pick.category = category
      pick
    end
  end

  def create_params
    params.expect(entry: [picks_attributes: [[:nominee_id, :category_id]]])
  end

  def update_params
    params.expect(entry: [picks_attributes: [[:id, :nominee_id]]])
  end
end
