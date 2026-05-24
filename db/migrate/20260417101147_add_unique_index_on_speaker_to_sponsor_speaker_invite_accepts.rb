class AddUniqueIndexOnSpeakerToSponsorSpeakerInviteAccepts < ActiveRecord::Migration[7.0]
  # 1 Speaker は 1 Conference 内で高々 1 Sponsor にしか紐付かない（Speaker : Sponsor = 1:1）
  # という不変条件を DB レベルでも強制する
  def change
    add_index :sponsor_speaker_invite_accepts,
              [:conference_id, :speaker_id],
              unique: true,
              name: 'idx_spk_inv_accepts_on_conf_speaker_uniq'
  end
end
