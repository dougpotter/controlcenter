# == Schema Information
# Schema version: 20101220202022
#
# Table name: jobs
#
#  id           :integer(4)      not null, primary key
#  type         :string(255)     not null
#  name         :string(255)     not null
#  parameters   :text            not null
#  created_at   :datetime        not null
#  status       :integer(4)      not null
#  state        :text            not null
#  completed_at :datetime
#

require 'spec_helper'

describe AppnexusSyncJob do
  it 'should be possible to instantiate one' do
    lambda do
      AppnexusSyncJob.new
    end.should_not raise_error
  end
end
