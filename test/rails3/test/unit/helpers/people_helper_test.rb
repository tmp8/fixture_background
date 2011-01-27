require 'test_helper'

class PeopleHelperTest < ActionView::TestCase
  background do 
    some_test_helper_returning_one
    @person = Person.create(:name => "one")
  end
  
  should "return reversed name" do
    assert_equal "eno", reverse_name(@person)
  end
end
