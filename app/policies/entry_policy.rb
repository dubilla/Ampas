class EntryPolicy < ApplicationPolicy
  def show?
    owner? || record.locked?
  end

  def create?
    user.present? && !record.locked? && !user.entries.exists?(pool_id: record.pool_id)
  end

  def update?
    owner? && !record.locked?
  end

  private

  def owner?
    user.present? && record.user_id == user.id
  end
end
