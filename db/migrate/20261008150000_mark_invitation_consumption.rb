class MarkInvitationConsumption < ActiveRecord::Migration[8.0]
  def up
    {
      sponsor_contact_invites: [:sponsor_contact_invite_accepts, :sponsor_contact_invite_id],
      sponsor_speaker_invites: [:sponsor_speaker_invite_accepts, :sponsor_speaker_invite_id],
      speaker_invitations: [:speaker_invitation_accepts, :speaker_invitation_id]
    }.each do |table, (accepts, foreign_key)|
      add_column table, :accepted_at, :datetime
      # 承認済みの既存招待も、担当者削除後に再利用されないよう記録する。
      execute <<~SQL
        UPDATE #{table}
        SET accepted_at = CURRENT_TIMESTAMP
        WHERE EXISTS (SELECT 1 FROM #{accepts} WHERE #{accepts}.#{foreign_key} = #{table}.id)
      SQL
    end
  end

  def down
    %i[sponsor_contact_invites sponsor_speaker_invites speaker_invitations].each do |table|
      remove_column table, :accepted_at
    end
  end
end
