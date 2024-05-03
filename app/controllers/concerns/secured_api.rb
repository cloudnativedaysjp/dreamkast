module SecuredApi
  extend ActiveSupport::Concern

  included do
    before_action :logged_in_using_omniauth?
  end

  def logged_in_using_omniauth?
    raise(Forbidden) unless logged_in?
  end
end
