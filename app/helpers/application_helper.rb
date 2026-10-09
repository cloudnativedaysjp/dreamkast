module ApplicationHelper
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

  # Markdownの表をサニタイズ後も残すため、標準の許可タグに表関連タグを加える
  MARKDOWN_ALLOWED_TAGS = (Rails::HTML::SafeListSanitizer.allowed_tags.to_a + %w[table thead tbody tr th td]).freeze

  def markdown(text)
    # 入力は管理者が編集する文章だが、全イベントが同一オリジンのためスクリプトを含むHTMLは除去する
    html_render = Redcarpet::Render::HTML.new(safe_links_only: true)
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
    sanitize(markdown.render(text.to_s), tags: MARKDOWN_ALLOWED_TAGS)
  end

  def event_js_path
    event_asset = if Conference.exists?(abbr: event_name) && event_name != 'cndt2020'
                    event_name
                  else
                    'application'
                  end
    return event_asset if asset_available?("#{event_asset}.css") && asset_available?("#{event_asset}.js")
    'application'
  end

  def weaver_query_url
    [
      ENV['DREAMKAST_WEAVER_ADDR'], 'query'
    ].join('/')
  end

  def alert_type(message_type)
    case message_type
    when 'notice'
      'success'
    when 'danger', 'alert'
      'danger'
    else
      'primary'
    end
  end

  def dk_alert_class(message_type)
    case alert_type(message_type)
    when 'success'
      'dk-alert-success'
    when 'danger'
      'dk-alert-danger'
    else
      'dk-alert-info'
    end
  end

  private

  def asset_available?(path)
    if Rails.env.production?
      Rails.application.assets_manifest&.assets&.[](path).present?
    else
      Rails.application.assets.find_asset(path).present?
    end
  end
end
