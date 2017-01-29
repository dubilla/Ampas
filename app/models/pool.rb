class Pool < ActiveRecord::Base
  belongs_to :award_ceremony
  has_many :entries
end
