class Entry < ActiveRecord::Base
  belongs_to :pool
  belongs_to :user
  has_many :picks
end
