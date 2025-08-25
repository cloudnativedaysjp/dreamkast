module Admin::TalkAttributesHelper
  def talk_attribute_checkboxes(talk)
    content_tag(:div, class: 'talk-attributes-wrapper', data: { talk_id: talk.id }) do
      TalkAttribute.ordered.map do |attribute|
        talk_attribute_checkbox(talk, attribute)
      end.join.html_safe
    end
  end

  def talk_attribute_checkbox(talk, attribute)
    is_checked = talk.talk_attributes.include?(attribute)
    checkbox_id = "talk_#{talk.id}_attr_#{attribute.id}"

    content_tag(:div, class: 'form-check form-check-inline') do
      concat(check_box_tag("talk_attributes[#{talk.id}][attribute_ids][]",
                           attribute.id,
                           is_checked,
                           {
                             id: checkbox_id,
                             class: 'form-check-input talk-attribute-checkbox',
                             data: {
                               exclusive: attribute.is_exclusive?,
                               talk_id: talk.id,
                               attr_id: attribute.id
                             }
                           }))

      concat(label_tag(checkbox_id, attribute.display_name, class: 'form-check-label text-sm'))
    end
  end

  def talk_attribute_display_tags(talk)
    if talk.talk_attributes.any?
      talk.talk_attributes.map do |attr|
        content_tag(:span, attr.display_name,
                    class: "badge #{attribute_badge_class(attr)} me-1")
      end.join.html_safe
    else
      content_tag(:span, '通常セッション', class: 'text-muted')
    end
  end

  def talk_attribute_summary(talk)
    attributes = talk.talk_attributes.pluck(:display_name)
    if attributes.any?
      attributes.join(' + ')
    else
      '通常セッション'
    end
  end

  private

  def attribute_badge_class(attribute)
    case attribute.name
    when 'keynote'
      'bg-primary'
    when 'sponsor'
      'bg-success'
    when 'intermission'
      'bg-warning text-dark'
    else
      'bg-secondary'
    end
  end
end
