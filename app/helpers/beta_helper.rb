module BetaHelper
  BETA_TEXT = 'β feature'.freeze
  def partial_beta_view(&block)
    if beta_user? || admin?
      p_tag = content_tag(:p, BETA_TEXT, class: 'beta-icon')
      p_tag.concat(content_tag(:div, capture(&block)))
      content_tag(:div, p_tag, class: 'beta-container')
    end
  end
end
