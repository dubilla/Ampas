class AddLocksTimeToAwardCeremony < ActiveRecord::Migration
  def change
    add_column :award_ceremonies, :locks_at, :datetime
  end
end
