class HttpClient::SpawnWgetNetrc < HttpClient::SpawnWget
  include SpawnNetrcMixin
  
  # wget always examines .netrc if it is present, no additional
  # command-line arguments are necessary
end
