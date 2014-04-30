## Metricular

A micro-gem for recording metrics within your Rails app.

### Installation

Add this line to your application's Gemfile:

```ruby
gem 'metricular'
```

And then execute:

```bash
$ bundle
```

Generate the required migration, and migrate your database:

```bash
$ ./bin/rails generate metricular:migration
$ ./bin/rake db:migrate
```

### Defining metrics to be recorded

To define a metric, give it a name, and write a proc that returns that metric's value. Your proc will receive a today's date as a parameter. This is useful if you want to record time-based metrics (eg. yesterday's revenue).

Metrics are defined using the following syntax:

```ruby
Metricular::Metric.define :name, proc { |date| ... }
```

A few examples:

```ruby
Metricular::Metric.define :all_time_conversion_rate, proc { Account.paid / Account.count.to_f }

Metricular::Metric.define :daily_trial_signups, proc do |date|
  Account.where(created_at: ((date-1.day)..date)).count
end

Metricular::Metric.define :activation_rate_within_7_days, proc do |date|
  # Find accounts that have had 7 days to activate
  accounts = Account.where(created_at: (date - 14.days)..(date - 7.days))
  accounts.where(activated: true).count / accounts.count.to_f
end
```

A good place to define your metrics is in an initializer (eg. in `config/initializers/metricular.rb`).

If you're defining a lot of metrics, you can re-open the Metricular::Metric class to keep things tidy:

```ruby
# config/initializers/metricular.rb
module Metricular
  class Metric
    define :foo, proc { |date| ... }
    define :bar, proc { |date| ... }
    define :baz, proc { |date| ... }
  end
end
```

### Recording your metrics

Ordinarily, you'll want to schedule a cron job to record your metrics, typically once a day. The [whenever gem](https://github.com/javan/whenever) is a good way to do this programatically, or if you're on Heroku, you can use the [Heroku scheduler](https://devcenter.heroku.com/articles/scheduler).

To record a value for every metric you have defined, simply call:

```ruby
Metricular::Metric.record_all
```

Alternatively, you can record a value for a specific metric:

```ruby
Metricular::Metric.record(:your_metric_name)
```

The `record` method takes an optional time, which can be useful for recording metrics for past data:

```ruby
Metricular::Metric.record(:your_metric_name, 1.week.ago)
```

There's also a rake task included in the gem that calls `Metricular::Metric.record_all` for you:

```bash
$ ./bin/rake metricular:record_all
```

### Accessing your metrics

`Metricular::Metric` inherits from `ActiveRecord::Base`, so querying your metrics is easy:

```ruby
# Retrieve metrics from the database
daily_signups_last_6_months = Metricular::Metric.where(name: :daily_trial_signups, created_at: 6.months.ago..Time.now)

# Do whatever you want with them
daily_signups_last_6_months.length
daily_signups_last_6_months.first
daily_signups_last_6_months.where(...)
daily_signups_last_6_months.select { ... }
```

Once you've accumulated some data you can graph your metrics, calculate aggregates, and query how they have changed over time.

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
