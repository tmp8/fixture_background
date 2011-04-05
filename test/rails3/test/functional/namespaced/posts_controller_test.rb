require 'test_helper'

class Namespaced::PostsControllerTest < ActionController::TestCase
  background do
  end

  should "get index" do
    get :index
    assert_response :success
  end
end
