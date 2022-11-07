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
    redirect_to(root_path, alert: 'ログインしてください')
  end

  def site_name
    if event_name && Conference.find_by(abbr: event_name).present?
      Conference.find_by(abbr: event_name).name
    else
      'CloudNative Days'
    end
  end

  def full_title(page_title = '')
    if event_name && Conference.find_by(abbr: event_name).present?
      base_title = Conference.find_by(abbr: event_name).name
      if page_title.empty?
        base_title
      else
        page_title + ' | ' + base_title
      end
    else
      'CloudNative Days'
    end
  end

  def event_image_url
    if event_name && Conference.find_by(abbr: event_name).present? && FileTest.exist?("#{Rails.root}/app/assets/images/#{event_name}/header_logo.png")
      image_url("#{event_name}/trademark.png")
    else
      image_url('trademark.png')
    end
  end

  def link_to_add_pdf_fields(name, f, association, **args)
    new_object = f.object.to_model.class.reflect_on_association(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + '_fields', f: builder)
    end
    link_to(name, '#', class: 'add_pdf_fields ' + args[:class], data: { id:, fields: fields.gsub("\n", '') }, style: args[:style])
  end

  def link_to_add_key_image_fields(name, f, association, **args)
    new_object = f.object.to_model.class.reflect_on_association(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + '_fields', f: builder)
    end
    link_to(name, '#', class: 'add_key_image_fields ' + args[:class], data: { id:, fields: fields.gsub("\n", '') }, style: args[:style])
  end

  def link_to_add_link_fields(name, f, association, **args)
    new_object = f.object.to_model.class.reflect_on_association(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + '_fields', f: builder)
    end
    link_to(name, '#', class: 'add_link_fields ' + args[:class], data: { id:, fields: fields.gsub("\n", '') }, style: args[:style])
  end

  def link_to_add_conference_day_fields(name, f, association, **args)
    new_object = f.object.to_model.class.reflect_on_association(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + '_fields', f: builder)
    end
    link_to(name, '#', class: 'add_conference_day_fields ' + args[:class], data: { id:, fields: fields.gsub("\n", '') }, style: args[:style])
  end

  def markdown(text)
    html_render = Redcarpet::Render::HTML
    options = {
      autolink: true,
      space_after_headers: true,
      no_intra_emphasis: true,
      fenced_code_blocks: true,
      tables: true,
      hard_wrap: true,
      xhtml: true,
      lax_html_blocks: true,
      strikethrough: true
    }
    markdown = Redcarpet::Markdown.new(html_render, options)
    markdown.render(text).html_safe
  end

  def event_js_path
    if Conference.all.map { |conf| conf.abbr }.include?(event_name) && event_name != 'cndt2020'
      event_name
    else
      'application'
    end
  end

  def vote_api_url(id)
    File.join(ENV['DREAMKAST_API_ADDR'], @conference.abbr, 'talks', id, 'vote')
  end

  def point_api_uri(profile_id)
    URI.parse("https://#{ENV['DREAMKAST_API_ADDR']}/api/v1/profile/#{profile_id}/point")
  end
end
