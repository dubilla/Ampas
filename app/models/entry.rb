class Entry < ApplicationRecord
  belongs_to :pool
  belongs_to :user
  # `inverse_of` must be explicit: the ordering scope above suppresses Rails'
  # automatic inverse detection, which leaves `pick.entry` nil while saving
  # nested attributes. Harmless until Rails 5 made `belongs_to` required.
  has_many :picks, -> { order(:created_at) }, dependent: :destroy, inverse_of: :entry
  accepts_nested_attributes_for :picks
  validates_associated :picks

  delegate :award_ceremony, to: :pool
  delegate :email, to: :user
  delegate :award_ceremony_name, to: :pool
  delegate :locks_at, to: :pool

  def name
    email
  end

  def locked?
    Time.current >= locks_at
  end

  def score
    picks.map(&:nominee).select(&:winner?).count
  end
end
