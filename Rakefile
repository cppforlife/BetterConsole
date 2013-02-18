require File.expand_path('lib/rake_config')
require File.expand_path('lib/rake_helper')

include RakeHelper

Dir['lib/tasks/*.rake'].each do |file|
  load File.expand_path(file)
end

task :default => "buildit:install"