require 'ostruct'

class ExtractionController < ApplicationController
  def index
    # put the end date a little into the future to guarantee that we are
    # seeing all currently available files
    end_date = Time.now.utc.beginning_of_day + 2.days
    lookback_days = 14
    start_date = end_date - lookback_days.days
    
    @bogus_files = DataProviderFile.all(
      :conditions => [
        'status=? and label_date is null and label_hour is null and discovered_at >= ?',
        DataProviderFile::DISCOVERED, Time.now - 7.days
      ],
      :order => 'discovered_at'
    )
    
    do_overview(start_date, end_date)
  end
  
  def details
    date = params[:date]
    @files = DataProviderFile.all(
      :conditions => ['name_date=?', date],
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
  
  def overview
    start_date = Time.utc(params[:year], params[:month])
    end_date = (start_date + 35.days).beginning_of_month - 1.day
    do_overview(start_date, end_date)
  end
  
  private
  
  def do_overview(start_date, end_date)
    lookback_days = (end_date - start_date) / 1.day
    @data = (0..lookback_days).map do |day|
      date = start_date + day.days
      date_str = date.strftime('%Y%m%d')
      day_data = OpenStruct.new(:date => date)
      # XXX if we had date/hour fields in data provider files
      # these queries could have been collapsed into one
      # and made more efficient via index usage
      counts = DataProviderFile.find_by_sql(<<-SQL)
        select status, count(*) as count
        from data_provider_files
        where name_date = #{DataProviderFile.quote_value("#{date_str}")}
        group by status
      SQL
      counts_map = {}
      counts.each do |count|
        counts_map[count.status] = count.count
      end
      day_data.counts = counts_map
      day_data
    end
    
    @previous_date = start_date - 1.day
    @next_date = end_date + 1.day
    
    render :action => 'overview'
  end
end
