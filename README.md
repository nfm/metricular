# Metricular

A micro-gem for recording metrics within your Rails app.

## Installation

Add this line to your application's Gemfile:

    gem 'metricular'

And then execute:

    $ bundle

Generate the required migration, and migrate your database:

    $ ./bin/rails generate metricular:migration
    $ ./bin/rake db:migrate

## Defining metrics to be recorded

To define a metric, give it a name, and write a proc that returns that metric's value. Your proc will receive a single parameter: today's date. You can use this to help you record time-sensitive metrics (eg. yesterday's revenue).

Metrics are defined using the following syntax:

    Metricular::Metric.define :name, proc { |date| ... }

A few examples:

    Metricular::Metric.define :daily_trial_signups, proc { |date| Account.where(created_at: ((date-1.day)..date)).count }

    Metricular::Metric.define :all_time_conversion_rate, proc { |_| Account.paid / Account.count.to_f }

    Metricular::Metric.define :activation_rate_within_7_days, proc do |date|
      # Find accounts that have had 7 days to activate
      accounts = Account.where(created_at: (date - 14.days)..(date - 7.days))
      accounts.where(activated: true).count / accounts.count.to_f
    end

A good place to define your metrics is in an initializer (eg. in `config/initializers/metricular.rb`).

If you're defining a lot of metrics, you can re-open the Metricular::Metric class to keep things tidy:

    # config/initializers/metricular.rb
    module Metricular
      class Metric
        define :foo, proc { |date| ... }
        define :bar, proc { |date| ... }
        define :baz, proc { |date| ... }
      end
    end

## Recording your metrics

Ordinarily, you'll want to schedule a cron job to record your metrics, typically once a day. The whenever gem is a good way to programatically handle this, or if you're running on Heroku, you can simply use the Heroku scheduler.

To record a value for every metric you have defined, simply call:

    Metricular::Metric.record_all

Alternatively, you can record a value for a specific metric:

    Metricular::Metric.record(:your_metric_name)

The `record` method takes an optional time, which can be useful for recording metrics for past data:

    Metricular::Metric.record(:your_metric_name, 1.week.ago)

There's also a rake task included in the gem that calls the `record_all` method:

    $ ./bin/rake metricular:record_all

## Accessing your metrics

`Metricular::Metric` inherits from `ActiveRecord::Base`, so querying your metrics is easy:

    # Retrieve metrics from the database
    daily_signups_last_6_months = Metricular::Metric.where(name: :daily_trial_signups, created_at: 6.months.ago..Time.now)

    # Do whatever you want with them
    daily_signups_last_6_months.length
    daily_signups_last_6_months.first
    daily_signups_last_6_months.where(...)
    daily_signups_last_6_months.select { ... }

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
