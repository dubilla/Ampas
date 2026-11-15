class AddIndexToPicksEntryId < ActiveRecord::Migration[4.2]
  def change
    add_index :picks, :entry_id
  end
end
