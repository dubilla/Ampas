class Entry < ActiveRecord::Base
  belongs_to :pool
  belongs_to :user
  has_many :picks

  delegate :award_ceremony, to: :pool
  delegate :email, to: :user
  delegate :award_ceremony_name, to: :pool
end
