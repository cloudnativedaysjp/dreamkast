module ApplicationHelper
  def current_user
    return unless session[:userinfo]
    @current_user ||= session[:userinfo]
  end

  def logged_in?
    !!session[:userinfo]
  end

  def authenticate
    return if logged_in?
    redirect_to root_path, alert: 'ログインしてください'
  end

  def message_box
    cls = ""
    unless @message_box
      @message_box = "#{Conference.find(1).name}へようこそ"
      cls = "d-none"
    end
    return "<div id=\"message_box\" class=\"#{cls}\"><p>#{@message_box}</p></div>"
  end

  def full_title(page_title = '')
    base_title = Conference.find(1).name
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

  def link_to_add_pdf_fields(name, f, association, **args)
    new_object = f.object.to_model.class.reflect_on_association(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, :child_index => id) do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to(name, '#', class: "add_pdf_fields " + args[:class], data: {id: id, fields: fields.gsub("\n", "")}, style: args[:style])
  end

  def link_to_add_key_image_fields(name, f, association, **args)
    new_object = f.object.to_model.class.reflect_on_association(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, :child_index => id) do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to(name, '#', class: "add_key_image_fields " + args[:class], data: {id: id, fields: fields.gsub("\n", "")}, style: args[:style])
  end

  def link_to_add_link_fields(name, f, association, **args)
    new_object = f.object.to_model.class.reflect_on_association(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, :child_index => id) do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to(name, '#', class: "add_link_fields " + args[:class], data: {id: id, fields: fields.gsub("\n", "")}, style: args[:style])
  end

end
