require 'spec_helper'

describe CampaignInventoryConfig do
  it "should create a new CampaignInventoryConfig given valid attributes" do
    Factory.create(:campaign_inventory_config)
  end

  it "should fail to create a duplicate (validations test)" do
    lambda {
      cic = Factory.create(:campaign_inventory_config)
      Factory.create( :campaign_inventory_config, 
        { 
          :campaign_id => cic.campaign_id, 
          :ad_inventory_source_id => cic.ad_inventory_source_id 
        }
      )
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should fail to create a duplicate (db test)" do
    cic_one = Factory.create(:campaign_inventory_config)
    lambda {
      cic_two = Factory.build(:campaign_inventory_config, 
        { 
          :campaign_id => cic_one.campaign_id, 
          :ad_inventory_source_id => cic_one.ad_inventory_source_id 
        }
      )
      cic_two.save(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should delete creative associations when destroyed" do
    @campaign_ic = Factory.create(:campaign_inventory_config)
    @creative_ic = Factory.create(
      :creative_inventory_config, 
      :campaign_inventory_config_id => @campaign_ic.id
    )
    
    expect {
      @campaign_ic.destroy
    }.to change { CreativeInventoryConfig.all.count }.by(-1)
  end
end
