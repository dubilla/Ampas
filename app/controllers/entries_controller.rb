class EntriesController < ApplicationController
  def show
    @entry = Entry.joins(pool: :award_ceremony).find(params[:id])
  end
end
