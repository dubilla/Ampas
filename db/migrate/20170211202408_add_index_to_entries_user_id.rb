class AddIndexToEntriesUserId < ActiveRecord::Migration[4.2]
  def change
    add_index :entries, :user_id
  end
end
