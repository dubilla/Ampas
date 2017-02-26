class Category < ActiveRecord::Base
  belongs_to :award_ceremony
  has_many :nominees

  def winner
    nominees.find(&:winner?)
  end
end
