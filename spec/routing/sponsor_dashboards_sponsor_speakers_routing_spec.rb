require 'rails_helper'

RSpec.describe('SponsorDashboards::SponsorSpeakers routing', type: :routing) do
  it 'スポンサー登壇者の直接登録 (#new) は sponsor_speakers コントローラにルーティングされない' do
    expect(get: '/cndt2020/sponsor_dashboards/1/sponsor_speakers/new')
      .not_to(route_to(controller: 'sponsor_dashboards/sponsor_speakers', action: 'new', event: 'cndt2020', sponsor_id: '1'))
  end

  it 'スポンサー登壇者の直接登録 (#create) は sponsor_speakers コントローラにルーティングされない' do
    expect(post: '/cndt2020/sponsor_dashboards/1/sponsor_speakers')
      .not_to(route_to(controller: 'sponsor_dashboards/sponsor_speakers', action: 'create', event: 'cndt2020', sponsor_id: '1'))
  end

  it '一覧 (#index) はルーティング可能' do
    expect(get: '/cndt2020/sponsor_dashboards/1/sponsor_speakers').to(be_routable)
  end

  it '編集 (#edit) / 更新 (#update) / 削除 (#destroy) はルーティング可能' do
    expect(get: '/cndt2020/sponsor_dashboards/1/sponsor_speakers/1/edit').to(be_routable)
    expect(patch: '/cndt2020/sponsor_dashboards/1/sponsor_speakers/1').to(be_routable)
    expect(delete: '/cndt2020/sponsor_dashboards/1/sponsor_speakers/1').to(be_routable)
  end
end
