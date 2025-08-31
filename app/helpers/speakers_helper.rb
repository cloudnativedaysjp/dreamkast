module SpeakersHelper
  def link_to_add_talk_fields(name, f, association, **args)
    new_object = Talk.new(conference: @conference)
    id = new_object.object_id
    fields = f.fields_for(:talks_attributes, new_object, child_index: id) do |builder|
      render("speaker_dashboard/speakers/#{association.to_s.singularize}_fields", f: builder, form_index: id)
    end
    link_to(name, '#', class: 'add_talk_fields ' + args[:class], data: { id:, fields: fields.gsub("\n", '') }, style: args[:style])
  end
end
