require 'test_helper'

class WorldObjectsControllerTest < ActionController::TestCase
  setup do
    @world_object = world_objects(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:world_objects)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create world_object" do
    assert_difference('WorldObject.count') do
      post :create, world_object: { arrow_height: @world_object.height, texture_url: @world_object.texture_url, type: @world_object.type, arrow_width: @world_object.width, x: @world_object.x, y: @world_object.y }
    end

    assert_redirected_to world_object_path(assigns(:world_object))
  end

  test "should show world_object" do
    get :show, id: @world_object
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @world_object
    assert_response :success
  end

  test "should update world_object" do
    put :update, id: @world_object, world_object: { arrow_height: @world_object.height, texture_url: @world_object.texture_url, type: @world_object.type, arrow_width: @world_object.width, x: @world_object.x, y: @world_object.y }
    assert_redirected_to world_object_path(assigns(:world_object))
  end

  test "should destroy world_object" do
    assert_difference('WorldObject.count', -1) do
      delete :destroy, id: @world_object
    end

    assert_redirected_to world_objects_path
  end
end
