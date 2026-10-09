module ValidatesInvitation
  extend ActiveSupport::Concern

  private

  # POST は呼び出し側のトランザクション内で招待をロックする。
  def find_valid_invitation!(model, token, acceptance, lock: false)
    raise ActiveRecord::RecordNotFound unless token.is_a?(String) && token.present?

    invitation = model.where(conference_id: current_conference.id).lock(lock).find_by!(token: token)
    reason = invalid_invitation_reason(invitation, acceptance)
    raise InvalidInvitation.new(reason) if reason

    invitation
  end

  # 招待が承諾できない理由を返す。承諾できる場合は nil を返す。
  def invalid_invitation_reason(invitation, acceptance)
    claims = current_user&.deep_stringify_keys || {}
    email = claims.dig('info', 'email')
    verified = claims.dig('extra', 'raw_info', 'email_verified')

    return :email_unverified unless verified == true
    return :email_mismatch unless email.present? && invitation.email.casecmp?(email)
    return :used if invitation.accepted_at.present? || invitation.public_send(acceptance).present?
    return :expired unless invitation.expires_at.present? && invitation.expires_at > Time.current

    nil
  end
end
