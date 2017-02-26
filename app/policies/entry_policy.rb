class EntryPolicy < ApplicationPolicy
  def show?
    (user.present? && user.entries.include?(record)) || record.locked?
  end

  def edit?
    user.entries.include?(record) && !record.locked?
  end
end
