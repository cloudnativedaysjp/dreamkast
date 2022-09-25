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
end
