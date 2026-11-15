class AddIndexToNomineeesCategoryId < ActiveRecord::Migration[4.2]
  def change
    add_index :nominees, :category_id
  end
end
