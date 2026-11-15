class EntryPolicy < ApplicationPolicy
  def show?
    owner? || record.locked?
  end

  def update?
    owner? && !record.locked?
  end

  private

  def owner?
    user.present? && user.entries.include?(record)
  end
end
