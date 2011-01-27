require 'test_helper'

class PeopleHelperTest < ActionView::TestCase
  background do 
    @person = Person.create(:name => "one")
  end
  
  should "return reversed name" do
    assert_equal "eno", reverse_name(@person)
  end
end
