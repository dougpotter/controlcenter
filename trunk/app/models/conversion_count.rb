# == Schema Information
# Schema version: 20101220202022
#
# Table name: conversion_counts
#
#  id                  :integer(4)      not null, primary key
#  campaign_id         :integer(4)      not null
#  start_time          :datetime        not null
#  end_time            :datetime        not null
#  duration_in_minutes :integer(4)      not null
#  conversion_count    :integer(4)      not null
#

class ConversionCount < ActiveRecord::Base
  acts_as_additive_fact

  belongs_to :campaign

  validates_presence_of :campaign_id, :start_time, :end_time, :duration_in_minutes, :conversion_count
  validates_numericality_of :conversion_count
  validates_as_increasing :start_time, :end_time
  validate :enforce_unique_index

  def enforce_unique_index
    if ConversionCount.exists?(self.attributes)
      errors.add_to_base('There already exists a ConversionCount with the same dimension combination')
    end
  end
end
