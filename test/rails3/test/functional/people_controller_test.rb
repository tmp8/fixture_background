require 'test_helper'

class PeopleControllerTest < ActionController::TestCase
  background do
    some_test_helper_returning_one
    @person = Person.create(:name => "one")
  end

  should "get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:people)
  end

  should "get new" do
    get :new
    assert_response :success
  end

  should "create person" do
    assert_difference('Person.count') do
      post :create, :person => @person.attributes
    end

    assert_redirected_to person_path(assigns(:person))
  end

  should "show person" do
    get :show, :id => @person.to_param
    assert_response :success
  end

  should "get edit" do
    get :edit, :id => @person.to_param
    assert_response :success
  end

  should "update person" do
    put :update, :id => @person.to_param, :person => @person.attributes
    assert_redirected_to person_path(assigns(:person))
  end

  should "destroy person" do
    assert_difference('Person.count', -1) do
      delete :destroy, :id => @person.to_param
    end

    assert_redirected_to people_path
  end
end
