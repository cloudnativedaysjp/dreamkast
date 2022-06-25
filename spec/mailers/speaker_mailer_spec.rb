require 'rails_helper'

RSpec.describe(SpeakerMailer, type: :mailer) do
  describe '#cfp_registered' do
    shared_examples_for :has_basic_information do
      it { is_expected.to(have_sent_email.with_subject("【#{conference.name}】プロポーザルを受け付けました")) }
      it { is_expected.to(have_sent_email.to(speaker.email)) }
      it { is_expected.to(have_sent_email.from('noreply@mail.cloudnativedays.jp')) }

      it { expect(mail.body.encoded).to(include("こんにちは、#{speaker.name} さん。")) }
      it { expect(mail.body.encoded).to(include("#{conference.name} のプロポーザルを以下の内容で受け付けました。")) }
      it { expect(mail.body.encoded).to(include("タイトル: #{talk.title}")) }
      it { expect(mail.body.encoded).to(include("概要: #{talk.abstract}")) }
      it { expect(mail.body.encoded).to(include("受講者レベル: #{talk.difficulty}")) }
      it { expect(mail.body.encoded).to(include("資料URL: #{talk.document_url}")) }
    end
    let!(:conference) { create(:one_day) }
    let!(:speaker) { create(:speaker_alice, conference: conference) }
    let!(:talk) { create(:talk1, conference: conference) }

    subject(:mail) { described_class.cfp_registered(conference, speaker, talk).deliver_now }

    describe 'has no proposal items' do
      it_should_behave_like :has_basic_information
    end

    describe 'has check box' do
      let!(:proposal_config_checkbox_1_a) { create(:check_box_item_config_1, conference: conference, params: '1-A') }
      let!(:proposal_config_checkbox_1_b) { create(:check_box_item_config_1, conference: conference, params: '1-B') }

      describe 'select one item (1-A)' do
        let!(:selected_checkbox_1) { create(:check_box_item_1, conference: conference, talk: talk, params: [proposal_config_checkbox_1_a.id.to_s]) }

        it_should_behave_like :has_basic_information

        it { expect(mail.body.encoded).to(include('チェックボックス1: 1-A')) }
      end

      describe 'select one item (1-B)' do
        let!(:selected_checkbox_1) { create(:check_box_item_1, conference: conference, talk: talk, params: [proposal_config_checkbox_1_b.id.to_s]) }

        it_should_behave_like :has_basic_information

        it { expect(mail.body.encoded).to(include('チェックボックス1: 1-B')) }
      end

      describe 'select two item' do
        let!(:selected_checkbox_1) { create(:check_box_item_1, conference: conference, talk: talk, params: [proposal_config_checkbox_1_a.id.to_s, proposal_config_checkbox_1_b.id.to_s]) }

        it_should_behave_like :has_basic_information

        it { expect(mail.body.encoded).to(include('チェックボックス1: 1-A, 1-B')) }
      end
    end

    describe 'has one radio button' do
      let!(:proposal_config_radio_button_3_a) { create(:radio_button_item_config_3, conference: conference,  params: '3-A') }
      let!(:proposal_config_radio_button_3_b) { create(:radio_button_item_config_3, conference: conference,  params: '3-B') }
      let!(:selected_radio_button_3) { create(:radio_button_item_3, conference: conference, talk: talk, params: proposal_config_radio_button_3_a.id.to_s) }

      it_should_behave_like :has_basic_information

      it { expect(mail.body.encoded).to(include('ラジオボタン3: 3-A')) }
    end

    describe 'has check box and radio button' do
      let!(:proposal_config_checkbox_1_a) { create(:check_box_item_config_1, conference: conference, params: '1-A') }
      let!(:proposal_config_checkbox_1_b) { create(:check_box_item_config_1, conference: conference, params: '1-B') }
      let!(:proposal_config_radio_button_3_a) { create(:radio_button_item_config_3, conference: conference,  params: '3-A') }
      let!(:proposal_config_radio_button_3_b) { create(:radio_button_item_config_3, conference: conference,  params: '3-B') }

      let!(:selected_checkbox_1) { create(:check_box_item_1, conference: conference, talk: talk, params: [proposal_config_checkbox_1_a.id.to_s]) }
      let!(:selected_radio_button_3) { create(:radio_button_item_3, conference: conference, talk: talk, params: proposal_config_radio_button_3_a.id.to_s) }

      it_should_behave_like :has_basic_information

      it { expect(mail.body.encoded).to(include('チェックボックス1: 1-A')) }
      it { expect(mail.body.encoded).to(include('ラジオボタン3: 3-A')) }
    end
  end

  describe '#inform_speaker_announcement' do
    shared_examples_for :has_basic_information do
      it { is_expected.to(have_sent_email.with_subject('oneday運営からのお知らせ')) }
      it { expect(mail.body.encoded).to(include("#{speaker.name}様")) }
      it { expect(mail.body.encoded).to(include('新しいお知らせが到着しました。')) }
      it { expect(mail.body.encoded).to(include('確認するには、イベントサイトのスピーカーダッシュボードをご確認ください。')) }
      it { expect(mail.body.encoded).to(include('https://event.cloudnativedays.jp/oneday')) }
    end
    subject(:mail) { described_class.inform_speaker_announcement(conference, speaker).deliver_now }
    let!(:conference) { create(:one_day) }
    let!(:speaker) { create(:speaker_alice, conference: conference) }

    it_should_behave_like :has_basic_information
  end
end
