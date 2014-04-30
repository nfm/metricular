module Metricular
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/metricular.rake'
    end
  end
end
