ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'fixture_background'
require 'rails/test_help'

class ActiveSupport::TestCase
  include ::FixtureBackground::ActiveSupport::TestCase
  
  fixtures :all
  
  def some_test_helper_returning_one
    1
  end
end  
