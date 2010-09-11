# Note: wget is unsuitable for working with https connections because it does
# not properly implement timeout functionality when ssl is involved.
# See upstream bug: http://savannah.gnu.org/bugs/index.php?20523
class HttpClient::SpawnWgetNetrc < HttpClient::SpawnWget
  include SpawnNetrcMixin
  
  private
  
  def build_command(*args)
    cmd = common_command_options
    cmd + args
  end
end
