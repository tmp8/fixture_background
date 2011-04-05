require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  
  background do
    some_test_helper_returning_one
    instance_test_helper_defined_after_background_returning_one
    @hase = Person.create(:name => "bunny")
  end

  def instance_test_helper_defined_after_background_returning_one
    1
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
  
  protected
  

end
