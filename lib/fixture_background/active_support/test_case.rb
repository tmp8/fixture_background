module FixtureBackground
  module ActiveSupport
    module TestCase
      extend ::ActiveSupport::Concern
  
      included do
        class_inheritable_accessor :background_ivar_cache
        class_inheritable_accessor :active_record_fixture_cache_resetted

        set_callback(:setup, :before, :reset_active_record_fixture_cache, {:prepend => true})
        set_callback(:setup, :before, :setup_background_ivars)
      end

      module ClassMethods
        def parent_fixture_background
          nil
        end
        
        def fixture_background
          @fixture_background
        end
        
        def background(&blk)
          @fixture_background = FixtureBackground::Background.new(name, self, nil, blk) 
        end
      end
  
      module InstanceMethods
        def setup_background_ivars
          return unless File.exist?("#{fixture_path}/ivars.dump")

          fill_background_ivar_cache unless background_ivar_cache
          background_ivar_cache.each do |ivar, record|
            # deep clone the object
            instance_variable_set(ivar, Marshal.load(Marshal.dump(record)))
          end
        end
    
        def fill_background_ivar_cache
          bm = Benchmark.realtime do
            self.background_ivar_cache = YAML.load_file("#{fixture_path}/ivars.dump")
            background_ivar_cache.each do |ivar, (class_name, id)|
              record = class_name.constantize.find(id)
              self.background_ivar_cache[ivar] = record
            end
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