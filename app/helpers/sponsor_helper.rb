module SponsorHelper
  def sponsor_logo_class(sponsor_type)
    case sponsor_type.name
    when 'Diamond', 'Special Collaboration'
      'tw-my-3 tw-w-full tw-px-3 md:tw-w-1/3'
    when 'Platinum'
      'tw-my-3 tw-w-full tw-px-3 md:tw-w-1/4'
    when 'Gold', 'Booth', 'Mini Session', 'CM', 'Tool', 'Logo'
      'tw-my-3 tw-w-full tw-px-3 md:tw-w-1/6'
    else
      'tw-my-3 tw-w-full tw-px-3 md:tw-w-1/4'
    end
  end
end
