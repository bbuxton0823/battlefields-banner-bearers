# frozen_string_literal: true

# This file contains configuration for RSpec and loads custom support files
# It should be required by the main spec/rails_helper.rb file

# Load all support files
Dir[File.join(File.dirname(__FILE__), '**', '*.rb')].sort.each do |file|
  require file unless file == __FILE__ # Don't require this file itself
end

RSpec.configure do |config|
  # Enable mocking and stubbing with RSpec's built-in mocking framework
  config.mock_with :rspec

  # Clean up any mocks after each test
  config.after(:each) do
    # Reset the BattleStateMock storage between tests if it's defined
    BattleStateMock.clear if defined?(BattleStateMock)
  end

  # Allow focusing on specific tests with focus: true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  # Use color in output
  config.color = true

  # Use the specified formatter
  config.formatter = :documentation

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  # Randomize test order for better isolation
  config.order = :random
  Kernel.srand config.seed
end
