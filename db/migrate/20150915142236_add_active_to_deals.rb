class AddActiveToDeals < ActiveRecord::Migration
  def self.up
    add_column :deals, :active, :boolean, :default => false
  end

  def self.down
    remove_column :deals, :active
  end
end
