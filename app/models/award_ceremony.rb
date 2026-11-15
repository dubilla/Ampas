class AwardCeremony < ApplicationRecord
  has_many :pools
  has_many :categories

  validates :locks_at, presence: true
end
