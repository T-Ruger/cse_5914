require "application_system_test_case"

class ViewingsTest < ApplicationSystemTestCase
  setup do
    @viewing = viewings(:one)
  end

  test "visiting the index" do
    visit viewings_url
    assert_selector "h1", text: "Viewings"
  end

  test "creating a Viewing" do
    visit viewings_url
    click_on "New Viewing"

    fill_in "Rating", with: @viewing.rating
    click_on "Create Viewing"

    assert_text "Viewing was successfully created"
    click_on "Back"
  end

  test "updating a Viewing" do
    visit viewings_url
    click_on "Edit", match: :first

    fill_in "Rating", with: @viewing.rating
    click_on "Update Viewing"

    assert_text "Viewing was successfully updated"
    click_on "Back"
  end

  test "destroying a Viewing" do
    visit viewings_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Viewing was successfully destroyed"
  end
end
