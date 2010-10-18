module Workflow
  # Contains methods common to verify workflows.
  #
  # Presence verification proceeds in three stages:
  #
  # 1. A set of existing files is computed by listing the appropriate data
  # source (either data provider or our data store).
  #
  # 2. User-supplied parameters (date and/or hour) are translated to a set of
  # criteria which are meaningful to the data provider. This step allows
  # workflows to account for different update frequencies and naming
  # conventions of their respective data providers.
  #
  # 3. Each criteria is evaluated against each of the existing files until
  # the criteria is satisfied (or we run out of files).
  #
  # A workflow may indicate that satisfying any one criteria will satisfy the
  # entire criteria set, or that satisfying all criteria is required to satisfy
  # the criteria set. An example of the former is a (Clearspring) channel which
  # is updated daily; a file timestamped with any hour of a day is considered
  # to fulfil data requirements for that day. An example of the latter is an
  # (akamai) channel which is updated every four hours; in this case we require
  # that every one of 24 hours has a corresponding file in the data source
  # (but note that six files would fulfil the requirements if appropriately
  # named).
  class VerifyBase < Base
    include EntryPoints::Verify
    
    expose_params :channel, :date, :hour, :s3_bucket
    
    # -----
    
    def list_bucket_items
      @s3_client.list_bucket_items(s3_bucket, build_s3_prefix)
    end
    
    def list_bucket_files
      @s3_client.list_bucket_files(s3_bucket, build_s3_prefix)
    end
    
    # -----
    
    def find_their_files
      data_source_urls = list_data_source_files
      check_existence(data_source_urls)
    end
    
    def find_our_files
      bucket_paths = list_bucket_files
      check_existence(bucket_paths)
    end
    
    # -----
    
    def check_correspondence(data_source_urls, our_paths)
      have, missing, partial = [], [], []
      data_source_urls.each do |url|
        remote_relative_path = url_to_relative_data_source_path(url)
        local_path = build_local_path(remote_relative_path)
        bucket_path = build_s3_path(local_path)
        
        ok = false
        if params[:trust_recorded]
          data_provider_file = DataProviderFile.find_by_url(url)
          if data_provider_file && data_provider_file.status == DataProviderFile::VERIFIED
            have << bucket_path
            ok = true
          end
        end
        
        if !ok
          extracted_paths = bucket_paths_under(our_paths, bucket_path)
          if ok = !extracted_paths.empty?
            if params[:check_sizes]
              source_size = @http_client.get_url_content_length(url)
              items = list_bucket_items
              extracted_items = extracted_paths.map do |path|
                items.detect { |item| item.path == path }
              end
              extracted_size = extracted_items.inject(0) do |sum, item|
                sum + item.size
              end
              if params[:check_sizes_exactly]
                ok = extracted_size == source_size
              else
                difference = (1 - extracted_size.to_f/source_size).abs
                if params[:check_sizes_strictly]
                  ok = difference < 0.1
                else
                  ok = difference < 0.2
                end
              end
            end
            if ok && params[:check_content]
            end
            if ok
              if params[:record]
                create_data_provider_file(url) do |file|
                  file.status = DataProviderFile::VERIFIED
                  file.verified_at = Time.now
                end
              end
              have << bucket_path
            else
              if params[:record]
                mark_data_provider_file_bogus(url)
              end
              
              bucket_path.instance_variable_set('@extracted_size', extracted_size)
              bucket_path.instance_variable_set('@source_size', source_size)
              
              class << bucket_path
                attr_reader :extracted_size, :source_size
              end
              
              partial << bucket_path
            end
          else
            if params[:record]
              mark_data_provider_file_bogus(url)
            end
            missing << bucket_path
          end
        end
      end
      [have, missing, partial]
    end
    
    def check_existence(items)
      options_list, require_all = compute_criteria_to_check
      have, missing = [], []
      if require_all
        options_list.each do |options|
          found = items.any? do |item|
            existence_check_fn(options, item)
          end
          if found
            have << {:date => options[:date], :hour => options[:hour]}
          else
            missing << {:date => options[:date], :hour => options[:hour]}
          end
        end
      else
        found = options_list.any? do |options|
          items.any? do |item|
            existence_check_fn(options, item)
          end
        end
        if found
          have << {:date => options_list.first[:date]}
        else
          missing << {:date => options_list.first[:date]}
        end
      end
      [have, missing]
    end
    
    # -----
    
    def report_correspondence(have, missing, partial)
      return if params[:quiet]
      have.each do |bucket_path|
        puts "Have #{channel.name} #{bucket_path}"
      end
      missing.each do |bucket_path|
        puts "Missing #{channel.name} #{bucket_path}"
      end
      partial.each do |bucket_path|
        puts "Partial #{channel.name} #{bucket_path}: extracted size #{bucket_path.extracted_size}, source size #{bucket_path.source_size}"
      end
    end
    
    def report_existence(have, missing)
      return if params[:quiet]
      have.each do |options|
        puts "Have #{channel.name} #{date_with_hour(options)}"
      end
      missing.each do |options|
        puts "Missing #{channel.name} #{date_with_hour(options)}"
      end
    end
    
    def date_with_hour(options)
      str = options[:date].to_s
      if options[:hour]
        str += sprintf('-%02d00', options[:hour])
      end
      str
    end
  end
end
