class AddColumnBulkOrderPriceInDeliveries < ActiveRecord::Migration
  def self.up
    add_column :deliveries, :bulk_order_price, :float, :default => 0.0  #unless RAILS_ENV == "production"
  end

  def self.down
    remove_column :deliveries, :bulk_order_price
  end
end
