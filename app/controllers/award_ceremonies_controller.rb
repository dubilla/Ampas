class AwardCeremoniesController < ApplicationController
  def index
    @award_ceremonies = AwardCeremony.all
  end
end
