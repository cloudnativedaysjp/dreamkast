namespace :ci do
  task check_git_diff: :environment do
    changes = `git diff | wc -l`

    unless changes.to_i.zero?
      puts `git diff`
      raise 'This branch has diff after db:migrate. Please confirm.'
    end
  end
end
