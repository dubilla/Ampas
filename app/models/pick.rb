class Pick < ApplicationRecord
  belongs_to :entry
  belongs_to :category
  # Deliberately optional: EntriesController#new builds picks with no nominee so
  # the form has a row per category. `complete?` below reports the missing
  # nominee, so a required belongs_to would only duplicate that error.
  belongs_to :nominee, optional: true

  validate :complete?
  validate :category_in_entry_ceremony
  validate :nominee_in_category

  private

  def category_in_entry_ceremony
    return unless category && entry&.pool
    unless category.award_ceremony_id == entry.pool.award_ceremony_id
      errors.add(:category, 'is not part of this award ceremony')
    end
  end

  def nominee_in_category
    return unless nominee && category
    unless nominee.category_id == category_id
      errors.add(:nominee, 'is not in this category')
    end
  end

  def complete?
    unless nominee.present?
      errors.add(:nominee, 'is missing')
    end
  end
end
