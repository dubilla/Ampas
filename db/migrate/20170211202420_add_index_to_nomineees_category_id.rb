class AddIndexToNomineeesCategoryId < ActiveRecord::Migration
  def change
    add_index :nominees, :category_id
  end
end
