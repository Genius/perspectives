require 'perspectives'
require 'ostruct'
require 'pry'

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.color_enabled = true
end

Perspectives.configure do |c|
  c.template_path = File.expand_path('../mustaches', __FILE__)
end

puts Perspectives.template_path
