-- This should account for most of mysql brain damage.
-- We cannot specify the passwords in this file, and by default
-- mysql will happily allow passwordless access with no warning.
-- If running the following statements produces an error like this:
--
-- ERROR 1133 (42000): Can't find any matching row in the user table
--
-- then the user must be created first:
--
-- create user xgcc_extract_rem@'10.%' identified by 'password';
set sql_mode = 'no_auto_create_user';

-- User names are restricted to 16 chars with a scary looking warning
-- to not attempt to lengthen them.
-- In this case I want xgcc_extract_remote.
grant select, insert, update, delete
	on xgcc_production.data_provider_channels
	to xgcc_extract_rem@'10.%';
grant select, insert, update, delete
	on xgcc_production.data_provider_files
	to xgcc_extract_rem@'10.%';
grant select, insert, update, delete
	on xgcc_production.data_providers
	to xgcc_extract_rem@'10.%';
grant select, insert, update, delete
	on xgcc_production.semaphore_allocations
	to xgcc_extract_rem@'10.%';
grant select, insert, update, delete
	on xgcc_production.semaphore_resources
	to xgcc_extract_rem@'10.%';
