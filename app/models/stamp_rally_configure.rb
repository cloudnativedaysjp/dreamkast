# == Schema Information
#
# Table name: stamp_rally_configures
#
#  id               :string(26)       not null, primary key
#  conference_id    :integer          not null
#  finish_threshold :decimal(10, )    not null
#
# Indexes
#
#  index_stamp_rally_configures_on_conference_id  (conference_id)
#

class StampRallyConfigure < ApplicationRecord
  include UlidPk
  belongs_to :conference
end
