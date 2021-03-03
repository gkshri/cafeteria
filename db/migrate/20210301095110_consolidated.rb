class Consolidated < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :password
      t.string :email
      t.integer :room
      t.integer :ext_room
      t.string :ppUrl

      t.timestamps
    end

    create_table :products do |t|
      t.string :name
      t.numeric :price

      t.timestamps
    end

    create_table :categories do |t|
      t.string :name

      t.timestamps
    end
    
    create_table :orders do |t|
      t.string :notes
      t.integer :room
      t.date :date

      t.timestamps
    end

    change_table :products do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :products, :image
  end

  change_table :users do |t|
    t.attachment :image
  end
end

def self.down
  remove_attachment :users, :image
end


  end
end
