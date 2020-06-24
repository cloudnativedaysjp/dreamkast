require 'test_helper'

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @profile = profiles(:one)
  end

  test "should get new" do
    get new_profile_url
    assert_response :success
  end

  test "should create profile" do
    assert_difference('Profile.count') do
      post profiles_url, params: { profile: { company_address: @profile.company_address, company_email: @profile.company_email, company_name: @profile.company_name, company_tel: @profile.company_tel, department: @profile.department, email: @profile.email, first_name: @profile.first_name, industry_id: @profile.industry_id, last_name: @profile.last_name, occupation: @profile.occupation, position: @profile.position, sub: @profile.sub } }
    end

    assert_redirected_to profile_url(Profile.last)
  end

  test "should get edit" do
    get edit_profile_url(@profile)
    assert_response :success
  end

  test "should update profile" do
    patch profile_url(@profile), params: { profile: { company_address: @profile.company_address, company_email: @profile.company_email, company_name: @profile.company_name, company_tel: @profile.company_tel, department: @profile.department, email: @profile.email, first_name: @profile.first_name, industry_id: @profile.industry_id, last_name: @profile.last_name, occupation: @profile.occupation, position: @profile.position, sub: @profile.sub } }
    assert_redirected_to profile_url(@profile)
  end

  test "should destroy profile" do
    assert_difference('Profile.count', -1) do
      delete profile_url(@profile)
    end

    assert_redirected_to profiles_url
  end
end
