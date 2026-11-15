class AddIndexToPicksNomineeId < ActiveRecord::Migration[4.2]
  def change
    add_index :picks, :nominee_id
  end
end
