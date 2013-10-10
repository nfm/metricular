module Metricular
  class Metric < ActiveRecord::Base
    # Return all metrics that have been defined
    def self.metrics
      @metrics
    end

    # Define a new metric for recording
    def self.define(name, block)
      @metrics ||= {}
      @metrics[name] = block
      scope name, -> { where(name: name) }
    end

    # Record data for all defined metrics
    def self.record_all
      @metrics.each { |name, block| record(name) }
    end

    # Record data for the specified metric, for the specified date
    def self.record(name, date = Time.now.utc)
      block = @metrics[name]
      value = block.call(date)
      find_or_create_by(name: name, date: date) { |metric| metric.value = value }
    end

    # Return an array of recorded metric data in [date, value] format
    def self.data
      all.map { |metric| [metric.date.to_time.to_i * 1000, metric.value.to_f] }
    end

    ####################
    # Stats
    ####################

    def self.mean
      (data.sum { |date, val| val }) / count.to_f
    end

    def self.variance
      mean = self.mean
      count = self.count
      (data.sum { |date, val| (val - mean) ** 2 }) / (count - 1).to_f
    end

    def self.standard_deviation
      return Math.sqrt(variance)
    end

    ####################
    # Scopes
    ####################

    # By default, order recorded metrics from oldest to newest
    default_scope { order('date ASC') }

    # Handy date range scopes
    scope :in_range, -> (start_date, end_date) { where('date > ? and date < ?', start_date, end_date) }
    scope :in_month, -> (month) { in_range(month.beginning_of_month, month.end_of_month) }
    scope :in_week, -> (week) { in_range(week.beginning_of_week, week.end_of_week) }
    scope :this_month, -> { in_month(Time.now.utc) }
    scope :last_month, -> { in_month(1.month.ago) }

    # Maximum and minimum scopes
    scope :maximum_value, -> { order('value DESC').limit(1).first }
    scope :minimum_value, -> { order('value ASC').limit(1).first }
  end
end
