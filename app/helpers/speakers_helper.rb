module SpeakersHelper
  def link_to_add_talk_fields(name, f, association, **args)
    new_object = f.object.to_model.class.reflect_on_association(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, :child_index => id) do |builder|
      puts "#{association.to_s.singularize + "_fields"}"
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to(name, '#', class: "add_talk_fields " + args[:class], data: {id: id, fields: fields.gsub("\n", "")}, style: args[:style])
  end

end
