module Admin::TalkTypesHelper
  def talk_type_checkboxes(talk)
    content_tag(:div, class: 'talk-types-wrapper', data: { talk_id: talk.id }) do
      TalkType.ordered.map do |type|
        talk_type_checkbox(talk, type)
      end.join.html_safe
    end
  end

  def talk_type_checkbox(talk, type)
    is_checked = talk.talk_types.include?(type)
    checkbox_id = "talk_#{talk.id}_type_#{type.id}"

    content_tag(:div, class: 'form-check form-check-inline') do
      concat(check_box_tag("talk_types[#{talk.id}][type_ids][]",
                           type.id,
                           is_checked,
                           {
                             id: checkbox_id,
                             class: 'form-check-input talk-type-checkbox',
                             data: {
                               exclusive: type.is_exclusive?,
                               talk_id: talk.id,
                               type_id: type.id
                             }
                           }))

      concat(label_tag(checkbox_id, type.display_name, class: 'form-check-label text-sm'))
    end
  end

  def talk_type_display_tags(talk)
    if talk.talk_types.any?
      talk.talk_types.map do |type|
        content_tag(:span, type.display_name,
                    class: "badge #{type_badge_class(type)} me-1")
      end.join.html_safe
    else
      content_tag(:span, '通常セッション', class: 'text-muted')
    end
  end

  def talk_type_summary(talk)
    types = talk.talk_types.pluck(:display_name)
    if types.any?
      types.join(' + ')
    else
      '通常セッション'
    end
  end

  private

  def type_badge_class(type)
    case type.name
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
