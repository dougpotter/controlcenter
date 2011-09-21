def run_svn_version_check
  scm_min_version = fetch(:scm_min_version, nil)
  if scm_min_version
    run <<-EOT
      svn --version | grep 'svn, version' |awk '{print $3}' |
      ruby -e "
        actual_text = STDIN.read.strip;
        actual = actual_text.split('.');
        required = '#{scm_min_version}'.split('.');
        required.each_with_index do |required_piece, index|
          actual_piece = actual[index];
          if required_piece.to_i > actual_piece.to_i then
            STDERR.puts \\\"Remote svn version too low: needed #{scm_min_version}, found \#{actual_text}\\\";
            exit 1;
          end
        end
      "
    EOT
  end
end

# Usage:
#
# before 'deploy:update_code', 'deploy:svn_version_check'
#
namespace :deploy do
  task :svn_version_check, :except => {:no_release => true} do
    run_svn_version_check
  end
end
