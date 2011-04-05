module FixtureBackground
  class Background
    
    class << self
      def class_for_test(full_class_name, background_to_use, test_unit_class)
        class_by_name(full_class_name) || create_class(full_class_name, test_unit_class, background_to_use)
      end

      def create_class(full_class_name, parent_class, background_to_use)
        klass = Class.new(parent_class)

        # Rails infers the Class to be tested by the name of the testcase
        klass.instance_eval <<-EOT
          def name
            "#{parent_class.name}"
          end
        EOT
        
        background_to_use.generate!
        
        klass.fixture_path = background_to_use.fixture_path
        klass.fixtures :all
        
        Object.const_set(full_class_name, klass)
      end

      def class_by_name(class_name)
        klass = Module.const_get(class_name)
        klass.is_a?(Class) && klass
      rescue NameError
        return false
      end
    end
    
    attr_reader :background_block
    
    def initialize(full_class_name, test_unit_class, parent, blk)
      @test_unit_class = test_unit_class
      @full_class_name = full_class_name
      @parent = parent
      @background_block = blk
      
      @generator = Generator.new(@full_class_name, background_signature, fixture_path, ancestors_and_own_background_blocks, @test_unit_class) unless background_valid?
    end
    
    def generate!
      @generator.generate! if @generator
    end
    
    def ancestors_and_own_background_blocks
      (@parent ? @parent.ancestors_and_own_background_blocks : []) << @background_block
    end

    def background_valid?
      (IO.read("#{fixture_path}/.version") rescue nil) == background_signature
    end

    def background_signature
      stack = caller.reject { |line| line =~ Regexp.new(File.dirname(__FILE__)) }
      test_file_path = File.expand_path(stack.first.match(/^(.+\.rb):/)[1])
      block_syntax = ''
      IO.read(test_file_path).scan(/(?:\A|\n)([ \t]*)background\s(?:do|{)(.*?)\n\1end/m) do |match|
        block_syntax << match[1].gsub(/\s+/, '')
      end
      Digest::MD5.hexdigest(block_syntax)
    end

    def fixture_path 
      Rails.root.to_s + "/test/backgrounds/#{@full_class_name.underscore}/"
    end
    
    def class_for_test
      self.class.class_for_test(@full_class_name, self, @test_unit_class)
    end
  end
end
