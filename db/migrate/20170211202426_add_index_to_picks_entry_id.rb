class AddIndexToPicksEntryId < ActiveRecord::Migration
  def change
    add_index :picks, :entry_id
  end
end
