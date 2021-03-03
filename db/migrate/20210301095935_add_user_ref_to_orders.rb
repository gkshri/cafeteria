class AddUserRefToOrders < ActiveRecord::Migration[5.0]
  def change
        add_reference :orders, :user, foreign_key: true,on_delete: :cascade
  end
end
