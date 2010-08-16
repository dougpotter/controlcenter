class CreateMsasAndZipsAndCountries < ActiveRecord::Migration
  def self.up
    create_table :msas do |t|
      t.string :msa_code, { :null => false, :length => 5 }
    end
    create_table :countries do |t|
      t.string :name, :null => false
    end
    create_table :zips do |t|
      t.string :zip, { :null => false, :length => 10 }
    end
  end

  def self.down
    drop_table :msas
    drop_table :countries
    drop_table :zips
  end
end
