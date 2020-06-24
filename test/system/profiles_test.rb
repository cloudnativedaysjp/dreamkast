require "application_system_test_case"

class ProfilesTest < ApplicationSystemTestCase
  setup do
    @profile = profiles(:one)
  end

  test "visiting the index" do
    visit profiles_url
    assert_selector "h1", text: "Profiles"
  end

  test "creating a Profile" do
    visit profiles_url
    click_on "New Profile"

    fill_in "Company address", with: @profile.company_address
    fill_in "Company email", with: @profile.company_email
    fill_in "Company name", with: @profile.company_name
    fill_in "Company tel", with: @profile.company_tel
    fill_in "Department", with: @profile.department
    fill_in "Email", with: @profile.email
    fill_in "First name", with: @profile.first_name
    fill_in "Industry", with: @profile.industry_id
    fill_in "Last name", with: @profile.last_name
    fill_in "Occupation", with: @profile.occupation
    fill_in "Position", with: @profile.position
    fill_in "Sub", with: @profile.sub
    click_on "Create Profile"

    assert_text "Profile was successfully created"
    click_on "Back"
  end

  test "updating a Profile" do
    visit profiles_url
    click_on "Edit", match: :first

    fill_in "Company address", with: @profile.company_address
    fill_in "Company email", with: @profile.company_email
    fill_in "Company name", with: @profile.company_name
    fill_in "Company tel", with: @profile.company_tel
    fill_in "Department", with: @profile.department
    fill_in "Email", with: @profile.email
    fill_in "First name", with: @profile.first_name
    fill_in "Industry", with: @profile.industry_id
    fill_in "Last name", with: @profile.last_name
    fill_in "Occupation", with: @profile.occupation
    fill_in "Position", with: @profile.position
    fill_in "Sub", with: @profile.sub
    click_on "Update Profile"

    assert_text "Profile was successfully updated"
    click_on "Back"
  end

  test "destroying a Profile" do
    visit profiles_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Profile was successfully destroyed"
  end
end
