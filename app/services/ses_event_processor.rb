class SesEventProcessor
  def self.process(payload)
    new(payload).process
  end

  def initialize(payload)
    @payload = payload
  end

  def process
    data = unwrap(@payload)
    event_type = data['eventType'] || data['notificationType']
    return if event_type.blank?

    case event_type
    when 'Bounce'
      process_bounce(data)
    when 'Complaint'
      process_complaint(data)
    when 'Delivery'
      process_delivery(data)
    end
  end

  private

  def unwrap(payload)
    data = payload.is_a?(String) ? JSON.parse(payload) : payload
    return data unless data.is_a?(Hash) && data['Type'] && data['Message']

    JSON.parse(data['Message'])
  end

  def headers_map(data)
    headers = data.dig('mail', 'headers') || []
    headers.each_with_object({}) do |header, map|
      name = header['name']
      value = header['value']
      map[name] = value
    end
  end

  def delivery_from_headers(data)
    headers = headers_map(data)
    delivery_id = headers['X-Announcement-Delivery-Id']
    return AnnouncementDelivery.find_by(id: delivery_id) if delivery_id.present?

    announcement_id = headers['X-Attendee-Announcement-Id']
    email = (data.dig('mail', 'destination') || []).first
    return if announcement_id.blank? || email.blank?

    AnnouncementDelivery.where(attendee_announcement_id: announcement_id, email:).order(sent_at: :desc).first
  end

  def process_bounce(data)
    delivery = delivery_from_headers(data)
    recipients = data.dig('bounce', 'bouncedRecipients') || []

    recipients.each do |recipient|
      email = recipient['emailAddress']
      next if email.blank?

      upsert_suppression(email, 'bounce')
      mark_delivery(delivery, email, 'bounced')
    end
  end

  def process_complaint(data)
    delivery = delivery_from_headers(data)
    recipients = data.dig('complaint', 'complainedRecipients') || []

    recipients.each do |recipient|
      email = recipient['emailAddress']
      next if email.blank?

      upsert_suppression(email, 'complaint')
      mark_delivery(delivery, email, 'complaint')
    end
  end

  def process_delivery(data)
    delivery = delivery_from_headers(data)
    return if delivery.nil?

    return if delivery.status == 'sent'

    delivery.update!(status: 'sent', sent_at: Time.zone.now)
    delivery.attendee_announcement.refresh_delivery_counts!
  end

  def upsert_suppression(email, reason)
    now = Time.zone.now
    suppression = EmailSuppression.find_by(email:)

    if suppression.present?
      suppression.update!(reason:, status: 'active', last_seen_at: now)
    else
      EmailSuppression.create!(
        email:,
        reason:,
        source: 'ses',
        status: 'active',
        first_seen_at: now,
        last_seen_at: now
      )
    end
  end

  def mark_delivery(delivery, email, status)
    return if delivery.nil?
    return if delivery.email != email

    delivery.update!(status:)
    delivery.attendee_announcement.refresh_delivery_counts!
  end
end
