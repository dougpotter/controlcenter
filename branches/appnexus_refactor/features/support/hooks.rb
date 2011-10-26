After('@clean_partners_from_apn_sandbox') do
  Partner.delete_all_apn
end
