class Entry < ApplicationRecord
  belongs_to :pool
  belongs_to :user
  # `inverse_of` must be explicit: the ordering scope above suppresses Rails'
  # automatic inverse detection, which leaves `pick.entry` nil while saving
  # nested attributes. Harmless until Rails 5 made `belongs_to` required.
  has_many :picks, -> { order(:created_at) }, dependent: :destroy, inverse_of: :entry
  accepts_nested_attributes_for :picks
  validates_associated :picks
  validate :one_pick_per_category
  validates :user_id, uniqueness: { scope: :pool_id, message: 'already has an entry in this pool' }

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

  private

  def one_pick_per_category
    category_ids = picks.reject(&:marked_for_destruction?).map(&:category_id)
    if category_ids.uniq.size < category_ids.size
      errors.add(:picks, 'can only include one pick per category')
    end
  end
end
