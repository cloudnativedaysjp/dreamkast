# == Schema Information
#
# Table name: stamp_rally_configures
#
#  id               :string(26)       not null, primary key
#  finish_threshold :decimal(10, )    not null
#  conference_id    :bigint           not null
#
# Indexes
#
#  index_stamp_rally_configures_on_conference_id  (conference_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#
class StampRallyConfigure < ApplicationRecord
  include UlidPk
  belongs_to :conference
end
