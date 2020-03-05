require 'test_helper'

class ViewingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @viewing = viewings(:one)
  end

  test "should get index" do
    get viewings_url
    assert_response :success
  end

  test "should get new" do
    get new_viewing_url
    assert_response :success
  end

  test "should create viewing" do
    assert_difference('Viewing.count') do
      post viewings_url, params: { viewing: { rating: @viewing.rating } }
    end

    assert_redirected_to viewing_url(Viewing.last)
  end

  test "should show viewing" do
    get viewing_url(@viewing)
    assert_response :success
  end

  test "should get edit" do
    get edit_viewing_url(@viewing)
    assert_response :success
  end

  test "should update viewing" do
    patch viewing_url(@viewing), params: { viewing: { rating: @viewing.rating } }
    assert_redirected_to viewing_url(@viewing)
  end

  test "should destroy viewing" do
    assert_difference('Viewing.count', -1) do
      delete viewing_url(@viewing)
    end

    assert_redirected_to viewings_url
  end
end
