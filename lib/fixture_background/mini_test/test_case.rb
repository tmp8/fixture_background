class ArrayWithTeardownSuiteCallback < Array
  
  def each
    super do |suite| 
      yield suite
      suite.teardown_suite_blocks.each(&:call) if suite.teardown_suite_blocks
    end
  end
end

class MiniTest::Unit::TestCase
   
  class_inheritable_accessor :teardown_suite_blocks

  class << self
    alias_method :test_suites_without_teardown, :test_suites

    def test_suites
      ArrayWithTeardownSuiteCallback.new(test_suites_without_teardown)
    end

    def teardown_suite(&block)
      (self.teardown_suite_blocks ||= []) << block
    end
  end
end