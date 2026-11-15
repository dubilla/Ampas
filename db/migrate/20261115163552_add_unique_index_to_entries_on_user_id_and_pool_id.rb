class AddUniqueIndexToEntriesOnUserIdAndPoolId < ActiveRecord::Migration[8.1]
  def change
    add_index :entries, [:user_id, :pool_id], unique: true
  end
end
