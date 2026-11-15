class AddLocksTimeToAwardCeremony < ActiveRecord::Migration[4.2]
  def change
    add_column :award_ceremonies, :locks_at, :datetime
  end
end
