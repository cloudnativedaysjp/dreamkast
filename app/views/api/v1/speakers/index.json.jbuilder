json.array!(@speakers) do |speaker|
  json.id(speaker.id)
  json.name(speaker.name)
  json.company(speaker.company)
  json.jobTitle(speaker.job_title)
  json.profile(speaker.profile)
  json.githubId(speaker.github_id)
  json.twitterId(speaker.twitter_id)
  json.avatarUrl(speaker.avatar_or_dummy_url(:medium))
end
