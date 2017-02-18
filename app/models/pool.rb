class Pool < ActiveRecord::Base
  belongs_to :award_ceremony
  has_many :entries
  has_many :categories, through: :award_ceremony

  delegate :name, to: :award_ceremony, prefix: true
  delegate :locks_at, to: :award_ceremony

  def locked?
    Time.current >= locks_at
  end
end
