class EntryPolicy < ApplicationPolicy
  def edit?
    user.entries.include? record
  end
end
