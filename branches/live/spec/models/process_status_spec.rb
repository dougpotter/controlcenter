require 'spec_helper'

describe ProcessStatus do
  # just a sanity check
  it "should call block given to set" do
    called = false
    ProcessStatus.set(:script => 'foo') do
      called = true
    end
    called.should == true
  end
  
  it "should set all parameters when given a left subset" do
    ProcessStatus.set(:script => 'extract') do
      $0.should == 'extract'
    end
    
    ProcessStatus.set(:script => 'extract', :params => 'now') do
      $0.should == 'extract: now'
    end
    
    ProcessStatus.set(:script => 'extract', :params => 'now', :action => 'fetch url') do
      $0.should == 'extract: now: fetch url'
    end
  end
  
  it "should change title when script is not given" do
    saved_title = $0
    
    ProcessStatus.set(:params => 'now') do
      $0.should == saved_title
    end
    
    ProcessStatus.set(:action => 'fetch url') do
      $0.should == saved_title
    end
  end
  
  it "should set left subset of parameters when there is a hole" do
    ProcessStatus.set(:script => 'extract', :action => 'fetch url') do
      $0.should == 'extract'
    end
  end
  
  it "should set all parameters when given in parts" do
    ProcessStatus.set(:script => 'extract') do
      $0.should == 'extract'
      ProcessStatus.set(:params => 'now') do
        $0.should == 'extract: now'
        ProcessStatus.set(:action => 'fetch url') do
          $0.should == 'extract: now: fetch url'
        end
      end
    end
    
    ProcessStatus.set(:script => 'extract', :params => 'now') do
      $0.should == 'extract: now'
      ProcessStatus.set(:action => 'fetch url') do
        $0.should == 'extract: now: fetch url'
      end
    end
    
    ProcessStatus.set(:script => 'extract') do
      $0.should == 'extract'
      ProcessStatus.set(:params => 'now', :action => 'fetch url') do
        $0.should == 'extract: now: fetch url'
      end
    end
  end
end
