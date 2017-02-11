class AddIndexToEntriesUserId < ActiveRecord::Migration
  def change
    add_index :entries, :user_id
  end
end
