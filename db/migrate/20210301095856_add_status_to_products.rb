class AddStatusToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :status, :boolean, default: true
  end
end
