class AddIndexToEntriesPoolId < ActiveRecord::Migration[4.2]
  def change
    add_index :entries, :pool_id
  end
end
