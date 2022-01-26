# == Schema Information
#
# Table name: links
#
#  id            :integer          not null, primary key
#  conference_id :integer          not null
#  title         :string(255)
#  url           :string(255)
#  description   :text(65535)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_links_on_conference_id  (conference_id)
#

require 'rails_helper'

RSpec.describe(Link, type: :model) do
  pending "add some examples to (or delete) #{__FILE__}"
end
