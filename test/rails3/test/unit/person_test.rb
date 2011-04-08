require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  
  setup do
    @instance_var_from_setup = nil
  end
  
  background do
    some_test_helper_returning_one
    instance_test_helper_defined_after_background_returning_one
    @hase = Person.create(:name => "bunny")
    @instance_var_from_setup = @hase
  end
  
  should "be set from background" do
    assert_not_nil @instance_var_from_setup
  end  
  
  context "setup instance vars" do
    background do
      @instance_var_from_setup = Person.create(:name => "igel")
    end
    
    should "be set from background" do
      assert_not_nil @instance_var_from_setup
    end
  end
  
  should "without context" do
    assert @hase
    assert_nil @thies
    assert_nil @manuel
    assert_nil @norman
  end
  
  should "not create post.yml" do
    assert !File.exist?(File.dirname(__FILE__) + '/../backgrounds/person_test/posts.yml')
  end
  
  context "with thies" do
    background do
      some_test_helper_returning_one
      instance_test_helper_defined_after_background_returning_one
      @thies = Person.create(:name => "thies")
    end
    
    should "be cool" do
      assert @hase
      assert @thies
      assert_nil @manuel
      assert_nil @norman
      assert_equal 2, Person.count
    end
  
    context "with manuel" do
      background do
        @manuel = Person.create(:name => "manuel")
      end
    
      should "be cool" do
        assert @hase
        assert @thies
        assert @manuel
        assert_nil @norman
        assert_equal 3, Person.count
      end
      
      context "with norman" do
        background do
          @norman = Person.create(:name => "norman")
        end
      
        should "be cool" do
          assert @hase
          assert @thies
          assert @manuel
          assert @norman
          assert_equal 4, Person.count
        end
      end
    end
  
    should "nother truth" do
      assert @hase
      assert @thies
      assert_nil @manuel
      assert_nil @norman
      assert_equal 2, Person.count
    end
  end
  
  private
    def instance_test_helper_defined_after_background_returning_one
      1
    end
end

class PersonWithoutGlobalBackgroundTest < ActiveSupport::TestCase

  context "main context" do
  
    background do
      @person = Person.create(:name => "person")
    end
        
    context "without explicit background" do
      should "instantiate ivars" do
        assert_not_nil @person
      end
    end
  end
end

class ZZZEmptyDatabaseTest < ActiveSupport::TestCase
  should "have a clean database" do
    assert_equal 0, Person.count
  end
end


class DontInheritTestsFromParentTestClassTest < ActiveSupport::TestCase
  
  context "index" do
    context "sports" do
      background do
      end

      should "ha" do
        assert_this_line_only_executed_once
      end
    end
    
    context "event_show_back_button_path" do
      should "da" do
        assert_this_line_only_executed_once
      end
    end
  end
  
  should "pa" do
    assert_this_line_only_executed_once
  end

  test "test" do
    assert_this_line_only_executed_once
  end
  
  def test_my_shit
    assert_this_line_only_executed_once
  end

  private
  
    def assert_this_line_only_executed_once
      key = caller[0]
      $assert_this_line_only_executed_once_memo ||= {}
      assert ! $assert_this_line_only_executed_once_memo[key]
      $assert_this_line_only_executed_once_memo[key] = true
    end
end
  