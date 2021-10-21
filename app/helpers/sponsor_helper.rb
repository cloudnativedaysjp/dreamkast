module SponsorHelper
  def sponsor_logo_class(sponsor_type)
    case sponsor_type.name
    when "Diamond", "Special Collaboration"
      "col-12 col-md-4 my-3 m-md-3"
    when "Platinum"
      "col-12 col-md-3 my-3 m-md-3"
    when "Gold", "Booth", "Mini Session", "CM", "Tool", "Logo"
      "col-12 col-md-2 my-3 m-md-3"
    else
      "col-12 col-md-3 my-3 m-md-3"
    end
  end
end