class AddIndexToCategoriesAwardCeremony < ActiveRecord::Migration[4.2]
  def change
    add_index :categories, :award_ceremony_id
  end
end
