module FixtureBackground
  class Generator
    def initialize(fixture_name, version, background_dir, blocks)
      @background_dir = background_dir
      remove_background_dir
      create_background_dir
      
      transaction_with_rollback do
        (ActiveRecord::Base.connection.tables - ["schema_migrations"]).each do |table_name|
          klass = table_name.classify.constantize
          klass.delete_all
        end
        
        bm = Benchmark.realtime do
          dump_ivars do |klass|
            blocks.each do |block|
              klass.instance_eval(&block)
            end
          end
          dump_fixtures
        end
        
        File.open("#{@background_dir}/.version", 'w+') do |f| 
          f.write version
        end
        
        puts "Instanciating #{fixture_name} took #{bm}ms"
      end
    rescue Exception
      remove_background_dir
      raise
    end
    
    private
      def transaction_with_rollback
        ActiveRecord::Base.connection.increment_open_transactions
        ActiveRecord::Base.connection.begin_db_transaction
        yield
        ActiveRecord::Base.connection.rollback_db_transaction
        ActiveRecord::Base.connection.decrement_open_transactions
      end
      
      def create_background_dir
        FileUtils.mkdir_p(@background_dir)
      end
      
      def remove_background_dir
        FileUtils.rm_rf(@background_dir)
      end
      
      def dump_ivars
        klass = Class.new
        existing_ivars = klass.instance_variables
        
        yield klass
        
        ivar_hash = {}
        (klass.instance_variables - existing_ivars).each do |ivar|
          record = klass.instance_variable_get(ivar)
          ivar_hash[ivar.to_s] = [record.class.name, record.id] if record.class.respond_to? :find
        end
        
        File.open("#{@background_dir}/ivars.dump", 'w+') do |f|
          YAML.dump(ivar_hash, f)
        end
      end
      
      def dump_fixtures
        (ActiveRecord::Base.connection.tables - ["schema_migrations"]).each do |table_name|
          klass = table_name.classify.constantize

          records = klass.all
          
          fixtures = {}
          records.each do |record|
            fixtures[table_name + record.id.to_s] = record.attributes
          end
          
          File.open("#{@background_dir}/#{table_name}.yml", 'w+') do |f|
            YAML.dump(fixtures, f)
          end
        end
      end
  end
end