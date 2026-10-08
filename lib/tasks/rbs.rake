if Rails.env.development?
  require 'rbs_rails/rake_task'
  RbsRails::RakeTask.new
end
