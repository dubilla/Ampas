class AddIndexToPoolsAwardCeremonyId < ActiveRecord::Migration[4.2]
  def change
    add_index :pools, :award_ceremony_id
  end
end
