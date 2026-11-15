class ChangeLocksAtNullOnAwardCeremonies < ActiveRecord::Migration[8.1]
  def change
    change_column_null :award_ceremonies, :locks_at, false
  end
end
