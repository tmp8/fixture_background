module FixtureBackground
  module ActiveSupport
    module TestCase
      extend ::ActiveSupport::Concern
  
      included do
        class_inheritable_accessor :background_ivars
        class_inheritable_accessor :active_record_fixture_cache_resetted
      end

      module ClassMethods
        def parent_fixture_background
          nil
        end
        
        def fixture_background
          @fixture_background
        end
        
        def background(&blk)
          set_callback(:setup, :before, :reset_active_record_fixture_cache, {:prepend => true})
          set_callback(:setup, :before, :setup_background_ivars)
          @fixture_background = FixtureBackground::Background.new(name, self, nil, blk)
        end
      end
  
      module InstanceMethods
        
        def setup_background_ivars
          self.background_ivars ||= IVars.deserialize((YAML.load_file("#{fixture_path}/ivars.dump") rescue {})) 

          deep_copy = Marshal.load(Marshal.dump(self.background_ivars))

          deep_copy.each do |ivar, record|
            instance_variable_set(ivar,record)
          end
        end
    
        def reset_active_record_fixture_cache
          return if active_record_fixture_cache_resetted
      
          Fixtures.class_variable_set(:@@all_cached_fixtures, {})
          self.active_record_fixture_cache_resetted = true
        end
      end
    end
  end
end