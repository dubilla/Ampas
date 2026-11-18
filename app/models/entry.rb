class Entry < ApplicationRecord
  belongs_to :pool
  belongs_to :user
  # `inverse_of` must be explicit: the ordering scope above suppresses Rails'
  # automatic inverse detection, which leaves `pick.entry` nil while saving
  # nested attributes. Harmless until Rails 5 made `belongs_to` required.
  has_many :picks, -> { order(:created_at) }, dependent: :delete_all, inverse_of: :entry
  accepts_nested_attributes_for :picks, reject_if: lambda { |attributes|
    attributes['id'].blank? && attributes['category_id'].blank?
  }
  validates_associated :picks
  validate :one_pick_per_category
  validate :pick_for_every_category, on: :create
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
    return unless category_ids.uniq.size < category_ids.size

    errors.add(:picks, 'can only include one pick per category')
  end

  def pick_for_every_category
    return unless pool

    picked = picks.reject(&:marked_for_destruction?).map(&:category_id)
    return unless (pool.categories.ids - picked).any?

    errors.add(:base, 'Pick a nominee in every category')
  end
end
