module ValidatesInvitation
  extend ActiveSupport::Concern

  private

  # POST は呼び出し側のトランザクション内で招待をロックする。
  def find_valid_invitation!(model, token, acceptance, lock: false)
    raise ActiveRecord::RecordNotFound unless token.is_a?(String) && token.present?

    invitation = model.where(conference_id: current_conference.id).lock(lock).find_by!(token: token)
    claims = current_user&.deep_stringify_keys || {}
    email = claims.dig('info', 'email')
    verified = claims.dig('extra', 'raw_info', 'email_verified')
    valid_email = verified == true && email.present? && invitation.email.casecmp?(email)
    used = invitation.accepted_at.present? || invitation.public_send(acceptance).present?
    raise Forbidden unless valid_email && invitation.expires_at.present? && invitation.expires_at > Time.current && !used

    invitation
  end
end
