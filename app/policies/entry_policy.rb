class EntryPolicy < ApplicationPolicy
  def edit?
    user.entries.include?(record) && !record.locked?
  end
end
