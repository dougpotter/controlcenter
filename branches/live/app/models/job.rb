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

# Persists information relating to background proceses, which we call jobs.
#
# The job table does not necessarily drive actual job execution;
# its purpose is to provide accountability for job execution, that is,
# if a job does not finish we may detect that condition by checking job
# table.
#
# Each job has a type. This column stores class name for Active Record
# single-table inheritance, and implicitly determines what parameters are
# allowed for a given job.
#
# Each job has a name. The name is the only free-form column in the job table;
# its purpose is to provide a human-readable name and/or description for the
# job. There is no requirement that job names be unique; jobs that are
# launched infrequently may share the same name, with creation time used
# for disambiguating jobs later. Jobs that are launched frequently should
# put additional identifying information into the name, perhaps copied from
# the parameters hash.
#
# Each job has parameters. Parameters are an arbitrary hash, which is stored
# serialized into yaml. If a job has no parameters the implementation takes
# care of serializing an empty hash.
#
# Each job has a status. The following statuses are currently defined:
#
#  * created
#  * processing
#  * completed
#  * failed
#
# Note that not all failures are detectable, and jobs that are in completed
# status may actually have failed in various ways.
#
# The reason for separating created and processing is that jobs may be
# performed by a process other than the one launching (creating) them.
#
# Jobs also have state. Similarly to parameters, this is an arbitrary hash
# that is serialized into yaml. State should contain any information
# necessary for checking and updating the job's status. For example, if
# a job involves spawning a process state may store that process' pid.
# A job which was created but is not yet running may not have any state, in
# which case state column in the database is filled with the serialization
# of an empty hash.
#
# Finally, jobs have a creation time and completion time. Creation time
# is always present, while completion time exists of the status is completed.
#
# Note that there is no provision for returning values from jobs. Jobs are
# like messages in that they are asynchronous, and there typically will not
# be anything waiting for a job's return value(s). Jobs are expected to write
# any output they produce into other locations, or perhaps launch additional
# jobs to process that output.
#
# Note: job parameters should not be set at the time of job initialization.
# Create a job and then use attribute assignment to set parameters instead.
class Job < ActiveRecord::Base
  CREATED = 1
  PROCESSING = 2
  COMPLETED = 3
  FAILED = 4
  
  serialize :parameters, Hash
  serialize :state, Hash
  
  class_inheritable_accessor :parameters_columns_hash
  self.parameters_columns_hash = {}
  
  named_scope :processing, :conditions => ['status=?', PROCESSING]
  
  def initialize(options={})
    default_options = {:parameters => {}, :state => {}, :status => CREATED}
    super(default_options.update(options))
  end
  
  private
  
  def append_diagnostics(text)
    if diag = self.state[:diagnostics]
      diag += "\n"
    else
      diag = ''
    end
    diag += text
    self.state[:diagnostics] = diag
  end
  
  def format_exception(exc)
    text = "#{e.class}: #{e.message}"
    exc.backtrace.each do |line|
      text += "\n#{line}"
    end
    text
  end
end
