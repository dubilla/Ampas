class Pool < ActiveRecord::Base
  belongs_to :award_ceremony
  has_many :entries

  delegate :name, to: :award_ceremony, prefix: true
end
