require 'test_helper'
require 'support/fake_resque_data_store'

class ResquesControllerTest < ActionController::TestCase
  setup do
    ResqueInstance.register_instance(name: "test1", resque_data_store: FakeResqueDataStore.new)
    ResqueInstance.register_instance(name: "test2", resque_data_store: FakeResqueDataStore.new)
  end
  test "index" do
    get :index, format: :json

    assert_response :success

    result = JSON.parse(response.body)
    assert result.include?("name" => "test1")
    assert result.include?("name" => "test2")
    assert_equal 2, result.size
  end

  test "show with nonexistent resque" do
    get :show, format: :json, id: "blah"
    assert_response :not_found
  end

  test "show with real resque" do
    get :show, format: :json, id: "test1"

    assert_response :success

    resque_instance = ResqueInstance.find("test1")

    result = JSON.parse(response.body)

    assert_equal resque_instance.name,result["name"]
    assert_equal resque_instance.running,result["running"]
    assert_equal resque_instance.running_too_long,result["runningTooLong"]
    assert_equal resque_instance.failed,result["failed"]
    assert_equal resque_instance.waiting,result["waiting"]
  end

end
