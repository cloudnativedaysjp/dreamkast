json.array!(@sponsors) do |sponsor|
  json.id(sponsor.id)
  json.eventAbbr(@conference.abbr)
  json.name(sponsor.name)
  json.abbr(sponsor.abbr)
  json.url(sponsor.url)
  json.logo_url(sponsor.logo_url ? image_url(sponsor.logo_url) : '')
  json.sponsorType(sponsor.sponsor_types.map { |type| type.name })
end
