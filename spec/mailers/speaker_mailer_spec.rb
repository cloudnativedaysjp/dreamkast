require "rails_helper"

RSpec.describe(SpeakerMailer, type: :mailer) do
  describe "#cfp_registered" do
    let!(:conference) { create(:one_day) }
    let!(:speaker) { create(:speaker_alice, conference: conference) }
    let!(:talk) { create(:talk1, conference: conference) }

    let!(:proposal_config_checkbox_1_a) { create(:check_box_item_config_1, conference: conference, params: "1-A") }
    let!(:proposal_config_checkbox_1_b) { create(:check_box_item_config_1, conference: conference, params: "1-B") }
    let!(:selected_checkbox_1) { create(:check_box_item_1, conference: conference, talk: talk, params: [proposal_config_checkbox_1_a.id.to_s, proposal_config_checkbox_1_b.id.to_s]) }

    let!(:proposal_config_checkbox_2_a) { create(:check_box_item_config_2, conference: conference,  params: "2-A") }
    let!(:proposal_config_checkbox_2_b) { create(:check_box_item_config_2, conference: conference,  params: "2-B") }
    let!(:selected_checkbox_2) { create(:check_box_item_2, conference: conference, talk: talk, params: [proposal_config_checkbox_2_a.id.to_s, proposal_config_checkbox_2_b.id.to_s]) }

    let!(:proposal_config_radio_button_3_a) { create(:radio_button_item_config_3, conference: conference,  params: "3-A") }
    let!(:proposal_config_radio_button_3_b) { create(:radio_button_item_config_3, conference: conference,  params: "3-B") }
    let!(:selected_radio_button_3) { create(:radio_button_item_3, conference: conference, talk: talk, params: proposal_config_radio_button_3_a.id.to_s) }

    subject(:mail) { described_class.cfp_registered(conference, speaker, talk).deliver_now }

    it "test" do
      puts mail.body.encoded
    end
  end
end
