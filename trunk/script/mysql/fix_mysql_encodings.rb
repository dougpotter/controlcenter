#!/usr/bin/env ruby
# fix_mysql_encodings.rb: Change character set encoding and collation to UTF-8
# for all MySQL databases/tables.

require File.expand_path('../../../config/boot',  __FILE__)
require File.expand_path('../../../config/environment',  __FILE__)

UTF8_CHARSET = "utf8"
UTF8_COLLATION = "utf8_general_ci"

rails_config = Rails::Configuration.new
db_name = rails_config.database_configuration[RAILS_ENV]["database"]

ActiveRecord::Base.connection.execute(
  "ALTER DATABASE #{db_name} DEFAULT CHARACTER SET = '#{UTF8_CHARSET}' " + 
  "DEFAULT COLLATE = '#{UTF8_COLLATION}';")

ActiveRecord::Base.connection.tables.each do |table_name|
  ActiveRecord::Base.connection.execute(
    "ALTER TABLE #{table_name} CONVERT TO CHARACTER SET '#{UTF8_CHARSET}' " + 
    "COLLATE '#{UTF8_COLLATION}';")
end
