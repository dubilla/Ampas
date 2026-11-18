class AddUniqueIndexToPicksOnEntryIdAndCategoryId < ActiveRecord::Migration[8.1]
  def change
    add_index :picks, %i[entry_id category_id], unique: true
  end
end
