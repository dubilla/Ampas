class AddCategoryToPick < ActiveRecord::Migration[4.2]
  def change
    add_reference :picks, :category, index: true
  end
end
