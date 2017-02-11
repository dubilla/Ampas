class AddIndexToCategoriesAwardCeremony < ActiveRecord::Migration
  def change
    add_index :categories, :award_ceremony_id
  end
end
