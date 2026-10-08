class MultipartUpload < ApplicationRecord
  belongs_to :user

  scope :active, -> { where('expires_at > ?', Time.current) }

  def expected_part_size(number)
    count = (byte_size.to_f / part_size).ceil
    raise ArgumentError unless number.between?(1, count)

    [part_size, byte_size - ((number - 1) * part_size)].min
  end
end
