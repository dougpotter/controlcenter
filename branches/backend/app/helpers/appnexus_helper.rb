module AppnexusHelper
  def appnexus_status_name(status)
    %w(None Created Processing Completed Failed)[status]
  end
  
  def shorten_emr_log_file_name(path)
    segments = path.split('/')
    segments.map! do |segment|
      if segment =~ /^(.+?)((?:\..{2,5})+$)/
        segment, ext = $1, $2
      else
        ext = ''
      end
      
      if segment.length > 20
        segment = segment[0..9] + '..' + segment[-10..-1]
      end
      
      segment + ext
    end
    segments.join('/')
  end
end
