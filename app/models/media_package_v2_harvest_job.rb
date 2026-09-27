require 'aws-sdk-mediapackagev2'

# MediaPackage V2 の HarvestJob でライブ配信の一部をアーカイブ動画として S3 に切り出す
# AWS 側のジョブ記録は作成から15日で消えるため、状態と出力先は DB に保持する
class MediaPackageV2HarvestJob < ApplicationRecord
  include EnvHelper
  include MediaPackageV2Helper
  include ArchiveBucketHelper

  STATUS_QUEUED = 'QUEUED'.freeze
  STATUS_IN_PROGRESS = 'IN_PROGRESS'.freeze
  STATUS_COMPLETED = 'COMPLETED'.freeze
  STATUS_CANCELLED = 'CANCELLED'.freeze
  STATUS_FAILED = 'FAILED'.freeze
  FINISHED_STATUSES = [STATUS_COMPLETED, STATUS_CANCELLED, STATUS_FAILED].freeze

  belongs_to :conference
  belongs_to :talk
  belongs_to :archive_origin_endpoint, class_name: 'MediaPackageV2ArchiveOriginEndpoint', foreign_key: :media_package_v2_archive_origin_endpoint_id, optional: true

  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_after_start_time

  delegate :streaming, to: :archive_origin_endpoint

  def create_aws_resource
    update!(bucket_name: archive_bucket_name, destination_path: "mediapackage/#{conference.abbr}/talks/#{talk_id}/#{id}")
    resp = media_package_v2_client.create_harvest_job(create_params)
    update!(harvest_job_name: resp.harvest_job_name, status: resp.status, error_message: resp.error_message)
  end

  # 実行中のジョブだけ AWS から状態を取り直す
  def refresh_status
    return if harvest_job_name.blank? || archive_origin_endpoint.nil? || finished?

    resp = media_package_v2_client.get_harvest_job(
      channel_group_name:,
      channel_name:,
      origin_endpoint_name: archive_origin_endpoint.origin_endpoint_name,
      harvest_job_name:
    )
    update!(status: resp.status, error_message: resp.error_message)
  rescue Aws::MediaPackageV2::Errors::NotFoundException => e
    logger.warn("harvest job #{harvest_job_name} not found: #{e.message}")
  end

  def finished?
    FINISHED_STATUSES.include?(status)
  end

  # TODO: 出力されるマニフェストのファイル名は staging で確認する
  def video_url
    return '' if bucket_name.blank? || destination_path.blank?

    "https://#{archive_cloudfront_domain_name(bucket_name)}/#{destination_path}/#{MediaPackageV2ArchiveOriginEndpoint::MANIFEST_NAME}.m3u8"
  end

  private

  def create_params
    {
      channel_group_name:,
      channel_name:,
      origin_endpoint_name: archive_origin_endpoint.origin_endpoint_name,
      harvest_job_name: "#{channel_group_name}_#{id}",
      harvested_manifests: {
        hls_manifests: [{ manifest_name: MediaPackageV2ArchiveOriginEndpoint::MANIFEST_NAME }]
      },
      schedule_configuration: {
        start_time:,
        end_time:
      },
      destination: {
        s3_destination: {
          bucket_name:,
          destination_path:
        }
      }
    }
  end

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?

    errors.add(:end_time, 'は開始時刻より後にしてください') if end_time <= start_time
  end
end
