class AwardCeremony < ActiveRecord::Base
  has_many :pools
  has_many :categories
end
