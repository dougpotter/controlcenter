module CampaignsHelper
  def options_from_audience_source_array(audience_sources, audience, selected = nil)
    container = []
    for audience_source in audience_sources
      text = "#{audience.iteration_for_source(audience_source)} :" + 
        " #{audience_source.s3_bucket}"
      value = audience_source.s3_bucket
      container << [ text, value ]
    end
    options_for_select(container, AudienceSource.find(selected).s3_bucket)
  end
end
