require 'test_helper'

class TrackControllerTest < ActionDispatch::IntegrationTest
  test "should redirect when someone didn't login" do
    get home_show_url
    assert_response :redirect
  end
end
