class Category < ActiveRecord::Base
  belongs_to :award_ceremony
  has_many :nominees
end
