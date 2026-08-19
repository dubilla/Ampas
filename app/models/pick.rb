class Pick < ApplicationRecord
  belongs_to :entry
  belongs_to :category
  # Deliberately optional: EntriesController#new builds picks with no nominee so
  # the form has a row per category. `complete?` below reports the missing
  # nominee, so a required belongs_to would only duplicate that error.
  belongs_to :nominee, optional: true

  validate :complete?

  private

  def complete?
    unless nominee.present?
      errors.add(:nominee, 'is missing')
    end
  end
end
