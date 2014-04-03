require 'rubygems'
require 'linear_perspective'
require 'ostruct'

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.color_enabled = true
end

LinearPerspective.configure do |c|
  c.template_path = File.expand_path('../mustaches', __FILE__)
end

puts LinearPerspective.template_path
