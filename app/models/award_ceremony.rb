class AwardCeremony < ApplicationRecord
  has_many :pools
  has_many :categories
end
