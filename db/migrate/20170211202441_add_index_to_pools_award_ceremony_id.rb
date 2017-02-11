class AddIndexToPoolsAwardCeremonyId < ActiveRecord::Migration
  def change
    add_index :pools, :award_ceremony_id
  end
end
