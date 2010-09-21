class ExtractionController < ApplicationController
  def status
    date = params[:date]
    @files = DataProviderFile.all(
      :conditions => ['url like ?', "%#{date}%"],
      :order => 'url'
    )
    @counts_by_status = @files.inject({}) do |counts, file|
      counts[file.status] = (counts[file.status] || 0) + 1
      counts
    end
  end
end
