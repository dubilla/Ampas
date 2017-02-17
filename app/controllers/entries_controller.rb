class EntriesController < ApplicationController

  before_action :authenticate_user!

  def new
    @entry = Entry.new
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
    @entry ||= Entry.joins(pool: :award_ceremony, picks: :category).find(params[:id])
  end

  def entry_params
    params
      .required(:entry)
      .permit(picks_attributes: [:id, :nominee_id, :category_id])
  end
end
