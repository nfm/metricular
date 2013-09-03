namespace :metricular do
  desc "Record data for all defined Metricular metrics"
  task record_all: :environment do
    Metricular::Metric.record_all
  end
end
