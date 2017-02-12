class EntriesController < ApplicationController
  def new
    @entry = Entry.new
  end

  def edit
    @entry = Entry.joins(pool: :award_ceremony).find(params[:id])
  end

  def show
    @entry = Entry.joins(pool: :award_ceremony).find(params[:id])
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

  def entry_params
    params
      .required(:entry)
      .permit(picks_attributes: [:id, :nominee_id, :category_id])
  end
end
