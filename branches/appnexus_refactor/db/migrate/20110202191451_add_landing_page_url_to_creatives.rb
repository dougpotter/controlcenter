class AddLandingPageUrlToCreatives < ActiveRecord::Migration
  def self.up
    add_column :creatives, :landing_page_url, :string
  end

  def self.down
    remove_column :creatives, :landing_page_url
  end
end
