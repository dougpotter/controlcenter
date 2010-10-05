require 'ostruct'

class ExtractionController < ApplicationController
  def index
    # put the end date a little into the future to guarantee that we are
    # seeing all currently available files
    end_date = Time.now.utc.beginning_of_day + 2.days
    lookback_days = 14
    start_date = end_date - lookback_days.days
    @data = (0..lookback_days).map do |day|
      date = start_date + day.days
      date_str = date.strftime('%Y%m%d')
      day_data = OpenStruct.new(:date => date)
      counts = DataProviderFile.find_by_sql(<<-SQL)
        select status, count(*) as count
        from data_provider_files
        where url like #{DataProviderFile.quote_value("%#{date_str}%")}
        group by status
      SQL
      counts_map = {}
      counts.each do |count|
        counts_map[count.status] = count.count
      end
      day_data.counts = counts_map
      day_data
    end
  end
  
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
    
    @date = Time.parse(date)
    @previous_day = (@date - 1.day).strftime('%Y%m%d')
    @next_day = (@date + 1.day).strftime('%Y%m%d')
  end
end
