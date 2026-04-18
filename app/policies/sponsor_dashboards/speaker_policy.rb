class SponsorDashboards::SpeakerPolicy < ApplicationPolicy
  # record: 対象の Speaker
  # speaker: pundit_user（このコントローラでは SponsorContact を入れる）
  #
  # スポンサー管理者が、自分の担当スポンサーに属する Speaker のみ編集・削除できることを保証する。

  def edit?
    belongs_to_my_sponsor?
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end

  private

  def belongs_to_my_sponsor?
    return false unless speaker

    # 経路1: 直接紐付く Speaker（legacy）
    return true if record.sponsor_id == speaker.sponsor_id

    # 経路2: SponsorSpeakerInviteAccept 経由（既存プロポーザル由来など）
    SponsorSpeakerInviteAccept.where(speaker_id: record.id, sponsor_id: speaker.sponsor_id).exists?
  end
end
