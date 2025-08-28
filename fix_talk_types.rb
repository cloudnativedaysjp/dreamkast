TalkType.where(name: '').each_with_index do |t, _i|
  t.update!(name: t.id.downcase, display_name: t.id)
end
puts "Updated #{TalkType.count} talk types"
