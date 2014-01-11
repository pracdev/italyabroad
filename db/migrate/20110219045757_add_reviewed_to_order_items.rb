class AddReviewedToOrderItems < ActiveRecord::Migration
  def self.up
   add_column :order_items,:reviewed,:boolean,:default=>false
  end

  def self.down
    remove_column :order_items,:reviewed
  end
end

