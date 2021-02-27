require 'test_helper'

class RequestConditionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @request_condition = request_conditions(:one)
  end

  test "should get index" do
    get request_conditions_url
    assert_response :success
  end

  test "should get new" do
    get new_request_condition_url
    assert_response :success
  end

  test "should create request_condition" do
    assert_difference('RequestCondition.count') do
      post request_conditions_url, params: { request_condition: { operation_type: @request_condition.operation_type, payment_code: @request_condition.payment_code, payment_type: @request_condition.payment_type, request_id: @request_condition.request_id, storage_center: @request_condition.storage_center } }
    end

    assert_redirected_to request_condition_url(RequestCondition.last)
  end

  test "should show request_condition" do
    get request_condition_url(@request_condition)
    assert_response :success
  end

  test "should get edit" do
    get edit_request_condition_url(@request_condition)
    assert_response :success
  end

  test "should update request_condition" do
    patch request_condition_url(@request_condition), params: { request_condition: { operation_type: @request_condition.operation_type, payment_code: @request_condition.payment_code, payment_type: @request_condition.payment_type, request_id: @request_condition.request_id, storage_center: @request_condition.storage_center } }
    assert_redirected_to request_condition_url(@request_condition)
  end

  test "should destroy request_condition" do
    assert_difference('RequestCondition.count', -1) do
      delete request_condition_url(@request_condition)
    end

    assert_redirected_to request_conditions_url
  end
end
