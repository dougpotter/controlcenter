class CreateMediaPurchaseMethods < ActiveRecord::Migration
  def self.up
    create_table :media_purchase_methods do |t|
      t.string :mpm_code
    end
  end

  def self.down
    drop_table :media_purchase_methods
  end
end
