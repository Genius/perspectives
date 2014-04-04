$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "perspectives/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "perspectives"
  s.version     = Perspectives::VERSION
  s.authors     = ["Andrew Warner"]
  s.email       = ["wwarner.andrew@gmail.com"]
  s.homepage    = "https://github.com/a-warner/perspectives"
  s.summary     = "View objects and logicless templates"
  s.description = "View objects and logicless templates"

  s.files = Dir["{app,config,db,lib,vendor}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_development_dependency "rails", "~> 4.0.3"
  s.add_development_dependency "rspec"
  s.add_development_dependency "pry"

  s.add_dependency "mustache", "~> 0.99.5"
  s.add_dependency "activesupport"
end
