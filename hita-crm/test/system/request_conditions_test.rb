require "application_system_test_case"

class RequestConditionsTest < ApplicationSystemTestCase
  setup do
    @request_condition = request_conditions(:one)
  end

  test "visiting the index" do
    visit request_conditions_url
    assert_selector "h1", text: "Request Conditions"
  end

  test "creating a Request condition" do
    visit request_conditions_url
    click_on "New Request Condition"

    fill_in "Operation type", with: @request_condition.operation_type
    fill_in "Payment code", with: @request_condition.payment_code
    fill_in "Payment type", with: @request_condition.payment_type
    fill_in "Request", with: @request_condition.request_id
    fill_in "Storage center", with: @request_condition.storage_center
    click_on "Create Request condition"

    assert_text "Request condition was successfully created"
    click_on "Back"
  end

  test "updating a Request condition" do
    visit request_conditions_url
    click_on "Edit", match: :first

    fill_in "Operation type", with: @request_condition.operation_type
    fill_in "Payment code", with: @request_condition.payment_code
    fill_in "Payment type", with: @request_condition.payment_type
    fill_in "Request", with: @request_condition.request_id
    fill_in "Storage center", with: @request_condition.storage_center
    click_on "Update Request condition"

    assert_text "Request condition was successfully updated"
    click_on "Back"
  end

  test "destroying a Request condition" do
    visit request_conditions_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Request condition was successfully destroyed"
  end
end
