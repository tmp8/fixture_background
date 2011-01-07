module FixtureBackground
  class Background
    attr_reader :background_block
    
    def initialize(full_class_name, test_unit_class, parent, blk)
      @test_unit_class = test_unit_class
      @full_class_name = full_class_name
      @parent = parent
      @background_block = blk
      
      Generator.new(@full_class_name, background_signature, fixture_path, ancestors_and_own_background_blocks) unless background_valid?
    end
    
    def ancestors_and_own_background_blocks
      (@parent ? @parent.ancestors_and_own_background_blocks : []) << @background_block
    end

    def background_valid?
      (IO.read("#{fixture_path}/.version") rescue nil) == background_signature
      false
    end

    def background_signature
      stack = caller.reject { |line| line =~ Regexp.new(__FILE__) }
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
      klass = Kernel.const_set(@full_class_name, Class.new(@test_unit_class))
      klass.fixture_path = fixture_path
      klass.fixtures :all
      klass 
    end
  end
end
