class GuestProfile
  attr_accessor :sub
  attr_accessor :email

  def id
    0
  end

  def talks
    []
  end

  def update
    true
  end

  def save
    true
  end

  # do not return method_missing
  # for methods to which Profile instance can respond,
  # but return an appropriate value
  def method_missing(method, *args)
    if Profile.new.respond_to?(method)
      Rails.logger.error("GuestProfile call goast method: #{method}")
      match = method.to_s.match(/(.*?)([?=!]?)$/)
      case match[2]
      when '='
        return args
      when '?'
        return true
      else
        return nil
      end
    end
    super
  end

  def respond_to_missing?(method, include_privete = false)
    Profile.new.respond_to?(method) || super
  end
end
