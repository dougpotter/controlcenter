class CampaignsMsas < ActiveRecord::Migration
  def self.up
		create_table :campaigns_msas, { :id => false } do |t|
			t.integer :campaign_id, :null => false
			t.integer :msa_id, :null => false
		end
  end

  def self.down
		drop_table :campaigns_msas
  end
end
