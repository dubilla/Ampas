class AddWinnerToNominee < ActiveRecord::Migration[4.2]
  def change
    add_column :nominees, :winner, :boolean
  end
end
