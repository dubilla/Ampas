class AddIndexToPicksNomineeId < ActiveRecord::Migration
  def change
    add_index :picks, :nominee_id
  end
end
