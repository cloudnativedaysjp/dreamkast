module Admin::TalksHelper
  def session_type_checkboxes(talk)
    TalkType.all.map do |type|
      checked = talk.talk_types.include?(type)
      check_box_tag(
        "talk_types[#{talk.id}][type_ids][]",
        type.id,
        checked,
        id: "talk_#{talk.id}_type_#{type.id}",
        class: 'session-type-checkbox',
        data: {
          talk_id: talk.id,
          type_name: type.name,
          exclusive: type.is_exclusive
        }
      ) + label_tag("talk_#{talk.id}_type_#{type.id}", type.display_name)
    end.join(' ').html_safe
  end
end
