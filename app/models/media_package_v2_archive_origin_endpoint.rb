require 'aws-sdk-mediapackagev2'

# HarvestJob でアーカイブ動画を切り出すための OriginEndpoint
# ライブ視聴用（LL-HLS / 1秒セグメント）とは分け、6秒セグメントの HLS を1週間遡れるようにしている
class MediaPackageV2ArchiveOriginEndpoint < ApplicationRecord
  include EnvHelper
  include MediaPackageV2Helper

  AWS_ACCOUNT_ID = '607167088920'.freeze
  MANIFEST_NAME = 'index'.freeze
  STARTOVER_WINDOW_SECONDS = 604_800 # 1 week

  before_create :set_uuid
  before_destroy :delete_aws_resource

  belongs_to :streaming
  belongs_to :channel, class_name: 'MediaPackageV2Channel', foreign_key: :media_package_v2_channel_id
  has_many :harvest_jobs, class_name: 'MediaPackageV2HarvestJob', foreign_key: :media_package_v2_archive_origin_endpoint_id, dependent: :nullify

  def create_aws_resource
    unless exists_aws_resource?
      resp = media_package_v2_client.create_origin_endpoint(
        {
          channel_group_name:,
          channel_name:,
          origin_endpoint_name:,
          container_type: 'TS',
          segment: {
            segment_duration_seconds: 6,
            segment_name: 'segment',
            ts_use_audio_rendition_group: false,
            include_iframe_only_streams: false,
            ts_include_dvb_subtitles: false
          },
          startover_window_seconds: STARTOVER_WINDOW_SECONDS,
          hls_manifests: [
            {
              manifest_name: MANIFEST_NAME,
              manifest_window_seconds: 60,
              program_date_time_interval_seconds: 1
            }
          ]
        }
      )
      media_package_v2_client.put_origin_endpoint_policy(
        {
          channel_group_name:,
          channel_name:,
          origin_endpoint_name:,
          policy:
        }
      )
      update!(name: resp.origin_endpoint_name)
    end
  end

  def exists_aws_resource?
    media_package_v2_client.get_origin_endpoint(channel_group_name:, channel_name:, origin_endpoint_name:)
    true
  rescue Aws::MediaPackageV2::Errors::NotFoundException
    false
  rescue => e
    logger.error(e.message)
    false
  end

  def delete_aws_resource
    if exists_aws_resource?
      media_package_v2_client.delete_origin_endpoint_policy(channel_group_name:, channel_name:, origin_endpoint_name:)
      media_package_v2_client.delete_origin_endpoint(channel_group_name:, channel_name:, origin_endpoint_name:)
      loop do
        break unless exists_aws_resource?
      end
    end
    update!(name: '')
  end

  def aws_resource
    @aws_resource ||= media_package_v2_client.get_origin_endpoint(channel_group_name:, channel_name:, origin_endpoint_name:)
  end

  # 管理画面のプレビュー用。?start=...&end=... を付けると過去の区間を再生できる
  def hls_manifest_url
    aws_resource&.hls_manifests&.first&.url
  rescue Aws::MediaPackageV2::Errors::NotFoundException
    nil
  end

  def origin_endpoint_name
    "#{super}_archive"
  end

  private

  def policy
    resource_arn = "arn:aws:mediapackagev2:#{AWS_LIVE_STREAM_REGION}:#{AWS_ACCOUNT_ID}:channelGroup/#{channel_group_name}/channel/#{channel_name}/originEndpoint/#{origin_endpoint_name}"
    {
      Version: '2012-10-17',
      Statement: [
        {
          Sid: 'AllowUser',
          Effect: 'Allow',
          Principal: '*',
          Action: 'mediapackagev2:GetObject',
          Resource: resource_arn
        },
        {
          Sid: 'AllowMediaPackageHarvestObjectAccess',
          Effect: 'Allow',
          Principal: { Service: 'mediapackagev2.amazonaws.com' },
          Condition: { StringEquals: { 'AWS:SourceAccount' => AWS_ACCOUNT_ID } },
          Action: ['mediapackagev2:HarvestObject', 'mediapackagev2:GetObject'],
          Resource: resource_arn
        }
      ]
    }.to_json
  end
end
