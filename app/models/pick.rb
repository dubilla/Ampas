class Pick < ActiveRecord::Base
  belongs_to :entry
  belongs_to :nominee
end
