require 'rails_helper'
require 'rake'

describe 'cleanup_profiles' do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('cleanup_profiles' , ["#{Rails.root}/lib/tasks"])
    Rake::Task.define_task(:environment)
    ENV["EVENT_ABBR"] = "cndt2020"
  end

  before(:each) do
    @rake[task].reenable
  end

  let!(:cndt2020) { create(:cndt2020, :opened) }
  let!(:alice) { create(:alice, :on_cndt2020, conference: cndt2020) }
  let!(:access_log) { create(:access_log, profile: alice) }
  let(:task) { 'util:cleanup_profiles' }

  it 'delete profiles related of conference' do
    @rake[task].invoke
    expect(Profile.where(conference_id: cndt2020.id).size).to(eq(0))
  end

  it 'delete access logs related of profile' do
    @rake[task].invoke
    expect(AccessLog.where(profile_id: alice.id).size).to(eq(0))
  end
end