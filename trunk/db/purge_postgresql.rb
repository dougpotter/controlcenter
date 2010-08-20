abcs = ActiveRecord::Base.configurations
ActiveRecord::Base.establish_connection(abcs['test'])
connection = ActiveRecord::Base.connection
connection.tables.each do |table|
  connection.execute("drop table #{connection.quote_table_name(table)} cascade")
end

