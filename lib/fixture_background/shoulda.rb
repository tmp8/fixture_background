module Shoulda
  raise "fixture_background is only compatible with shoulda 2.11.3 installed #{VERSION}" if VERSION != "2.11.3"

  class Context
    attr_reader :fixture_background
    
    def full_class_name
      (test_unit_class.name + full_name.gsub(/\s+/, '_')).camelcase
    end

    def parent_fixture_background
      if parent && parent.respond_to?(:fixture_background)
        parent.fixture_background || parent.parent_fixture_background
      end
    end
    
    def background(&blk)
      @fixture_background = FixtureBackground::Background.new(full_class_name, test_unit_class, parent_fixture_background, blk) 
    end
    
    def class_for_test
      @fixture_background ? @fixture_background.class_for_test : test_unit_class
    end

    
    #
    # the following functions are copied from shoulda/context.rb
    #
    
    def create_test_from_should_hash(klass, should)
      test_name = ["test:", full_name, "should", "#{should[:name]}. "].flatten.join(' ').to_sym

      if klass.instance_methods.include?(test_name.to_s)
        warn "  * WARNING: '#{test_name}' is already defined"
      end

      context = self
      klass.send(:define_method, test_name) do
        @shoulda_context = context
        begin
          context.run_parent_setup_blocks(self)
          should[:before].bind(self).call if should[:before]
          context.run_current_setup_blocks(self)
          should[:block].bind(self).call
        ensure
          context.run_all_teardown_blocks(self)
        end
      end
    end
    
    def build
      klass = class_for_test
      
      shoulds.each do |should|
        create_test_from_should_hash(klass, should)
      end

      subcontexts.each { |context| context.build }

      print_should_eventuallys
    end
  end
end
