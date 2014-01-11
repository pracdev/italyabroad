class ChangePriceAndQunatityColumnOfProducts < ActiveRecord::Migration
  def self.up
    change_column :products, :price, :string, :default => 0
    change_column :products, :quantity, :string, :default => 1
  end

  def self.down
    change_column :products, :quantity, :integer, :default => 1
    change_column :products, :price, :float, :default => 0
  end
end
