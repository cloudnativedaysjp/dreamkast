module Admin::TalksHelper
  def session_attribute_checkboxes(talk)
    TalkAttribute.all.map do |attribute|
      checked = talk.talk_attributes.include?(attribute)
      check_box_tag(
        "talk_attributes[#{talk.id}][attribute_ids][]",
        attribute.id,
        checked,
        id: "talk_#{talk.id}_attribute_#{attribute.id}",
        class: 'session-attribute-checkbox',
        data: {
          talk_id: talk.id,
          attribute_name: attribute.name,
          exclusive: attribute.is_exclusive
        }
      ) + label_tag("talk_#{talk.id}_attribute_#{attribute.id}", attribute.display_name)
    end.join(' ').html_safe
  end
end
