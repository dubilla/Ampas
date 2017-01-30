class Pick < ActiveRecord::Base
  belongs_to :entry
  belongs_to :category
  belongs_to :nominee
end
