require 'spec_helper'

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

Bundler.require(:test)

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!
