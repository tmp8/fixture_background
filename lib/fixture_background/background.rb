module FixtureBackground
  class << self
    
    def clean_database!
      (ActiveRecord::Base.connection.tables - ["schema_migrations"]).each do |table_name|
        ActiveRecord::Base.connection.execute "DELETE FROM #{table_name}"
      end
    end
  end
  
  class Background
    
    class << self
      def class_for_test(full_class_name, background_to_use, test_unit_class)
        full_class_name = full_class_name.gsub("::", "__")
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
        
        klass.class_eval <<-EOT
          cattr_accessor :fixture_background
          @@background_generated = false
          @@fixtures_enabled = false
          
          def initialize(*args)
            super

            if background = fixture_background
              if !@@background_generated
                background.generate!
                @@background_generated = true
              end
              if !@@fixtures_enabled
                self.class.fixtures :all
                self.class.teardown_suite { FixtureBackground.clean_database! }
                @@fixtures_enabled = true
              end
            end
          end
        EOT
        
        klass.fixture_background = background_to_use
        klass.fixture_path = background_to_use.fixture_path
        
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
      
      FixtureBackground.clean_database!
      test_unit_class.set_callback(:setup, :before, :reset_active_record_fixture_cache, {:prepend => true})
      test_unit_class.set_callback(:setup, :before, :setup_background_ivars)  
      
      @generator = Generator.new(
        @full_class_name, background_signature, fixture_path,
        ancestors_and_own_background_blocks, @test_unit_class
      ) unless background_valid?
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
