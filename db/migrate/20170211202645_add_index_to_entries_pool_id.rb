class AddIndexToEntriesPoolId < ActiveRecord::Migration
  def change
    add_index :entries, :pool_id
  end
end
