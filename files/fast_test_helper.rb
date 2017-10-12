ENV['RAILS_ENV'] = 'test'

# Setup default load-paths
PATHS = %w(
  app/models
  app/models/concerns
  app/domain
  app/helpers
  app/controllers
  app/controllers/concerns
  lib
)
for path in PATHS
  $LOAD_PATH << File.expand_path("../#{path}", File.dirname(__FILE__))
end

require 'minitest/autorun'
require 'support/minitest_reporters'
require 'support/mocha'

require 'active_support'
require 'active_support/all'


# Set test examples ordering inside a test file
ActiveSupport.test_order = :sorted

# Optional Pry require - with plugins adds ~.35s to boot time
# If not required here, you can still require it explicitly inside the test.
require 'byebug' if ENV['BYEBUG']

unless defined?(require_dependency)
  alias :require_dependency :require
end
