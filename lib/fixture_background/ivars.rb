module FixtureBackground
  class IVars
    class << self
      def serialize(value)
        case value 
        when Hash
          value.inject({}) do |memo, (key, v)| 
            memo[key] = serialize(v)
            memo
          end
        when Array
          value.map { |v| serialize(v) }
        else 
          if value.class.respond_to?(:find) && value.respond_to?(:id) 
            "#{value.class.name}##{value.id}"
          else
            raise ArgumentError
          end
        end
      end
      
      def deserialize(value)
        case value
        when Hash
          value.inject({}) do |memo, (key, v)| 
            memo[key] = deserialize(v)
            memo
          end
        when Array
          value.map { |v| deserialize(v) }
        when String
          klass, id = value.split("#")
          klass.constantize.find(id)
        end
      end
    end
  end
end

if __FILE__ == $0
  require 'test/unit'
  gem "activesupport"
  require 'active_support/all'
  
  include FixtureBackground

  class Record
    attr_reader :id
    
    class << self
      def find(id)
        new(id)
      end
    end

    def initialize(id) 
      @id = id.to_i
    end
    
    def ==(other)
      other.class == Record && other.id == id
    end
  end

  class IVarsTest < Test::Unit::TestCase
    def test_serialize_simple_values
      data = {
        :hase => Record.find(1), 
        :igel => Record.find(2)
      }

      expected = {
        :hase => 'Record#1',
        :igel => 'Record#2'
      }
      
      assert_serialize_deserialize expected, data
    end
    
    def test_serialize_arrays
      data = {
        :hase => [Record.find(1), Record.find(2), [Record.find(3), Record.find(4)]] 
      }

      expected = {
        :hase => ['Record#1', 'Record#2', ['Record#3', 'Record#4']]
      }
      
      assert_serialize_deserialize expected, data
    end

    def test_serialize_hash
      data = {
        :hase => { 'thies' => [Record.find(1), Record.find(2)], :sebastian => [Record.find(3), Record.find(4)]}
      }

      expected = {
        :hase => {'thies' => ['Record#1', 'Record#2'], :sebastian => ['Record#3', 'Record#4']}
      }
      
      assert_serialize_deserialize expected, data
    end

    def test_raises_exception_if_some_var_does_not_respond_to_find
      data = [
        :some => 1
      ]
      
      assert_raises(ArgumentError) { IVars.serialize(data) }
    end
  end
  
  def assert_serialize_deserialize(expected, data)
    serialized = IVars.serialize(data)
    deserialized = IVars.deserialize(serialized)
    
    assert_equal expected, serialized
    assert_equal deserialized, data
  end
end


