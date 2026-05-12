module AdminHelper
  def admin_env_label
    case ENV['DREAMKAST_NAMESPACE']
    when 'dreamkast'
      { name: 'Production', css_class: 'env-label-production' }
    when 'dreamkast-staging'
      { name: 'Staging', css_class: 'env-label-staging' }
    else
      { name: 'Dev', css_class: 'env-label-dev' }
    end
  end
end
