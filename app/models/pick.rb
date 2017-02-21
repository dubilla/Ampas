class Pick < ActiveRecord::Base
  belongs_to :entry
  belongs_to :category
  belongs_to :nominee

  validate :complete?

  private

  def complete?
    unless nominee.present?
      errors.add(:nominee, 'is missing')
    end
  end
end
