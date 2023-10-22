# == Schema Information
#
# Table name: media_package_v2_origin_endpoints
#
#  id                          :string(255)      not null, primary key
#  name                        :string(255)
#  media_package_v2_channel_id :string(255)
#  streaming_id                :string(255)      not null
#
# Indexes
#
#  index_media_package_v2_origin_endpoints_on_name          (name) UNIQUE
#  index_media_package_v2_origin_endpoints_on_streaming_id  (streaming_id)
#  index_origin_endpoints_on_channel_id                     (media_package_v2_channel_id)
#
# Foreign Keys
#
#  fk_rails_...  (streaming_id => streamings.id)
#
require 'aws-sdk-mediapackagev2'
require 'aws-sdk-cloudfront'

class MediaPackageV2OriginEndpoint < ApplicationRecord
  include EnvHelper
  include MediaPackageV2Helper
  include CloudfrontHelper

  before_create :set_uuid
  before_destroy :delete_aws_resource

  belongs_to :streaming
  belongs_to :channel, class_name: 'MediaPackageV2Channel', foreign_key: :media_package_v2_channel_id

  def create_aws_resource
    unless exists_aws_resource?
      resp = media_package_v2_client.create_origin_endpoint(
        {
          channel_group_name:,
          channel_name:,
          origin_endpoint_name:,
          container_type: 'TS',
          segment: {
            segment_duration_seconds: 1,
            segment_name: 'segment',
            ts_use_audio_rendition_group: false,
            include_iframe_only_streams: false,
            ts_include_dvb_subtitles: false
          },
          startover_window_seconds: 60,
          low_latency_hls_manifests: [
            {
              manifest_name: 'll-hls-index',
              manifest_window_seconds: 30,
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
          policy: <<~EOS
            {
              "Version": "2012-10-17",
              "Statement": [
                {
                  "Sid": "AllowUser",
                  "Effect": "Allow",
                  "Principal": "*",
                  "Action": "mediapackagev2:GetObject",
                  "Resource": "arn:aws:mediapackagev2:us-west-2:607167088920:channelGroup/#{channel_group_name}/channel/#{channel_name}/originEndpoint/#{origin_endpoint_name}"
                }
              ]
            }
          EOS
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
    @aws_resource ||= media_package_v2_client.get_origin_endpoint(channel_group_name:, channel_name:, origin_endpoint_name:) if origin_endpoint_name
  end

  def playback_url
    origin_url = aws_resource&.low_latency_hls_manifests&.first&.url
    resp = cloudfront_client.get_distribution({ id: distribution_id })
    "https://#{resp.distribution.domain_name}#{URI.parse(origin_url).path}"
  rescue Aws::MediaPackageV2::Errors::NotFoundException
    ''
  end

  def remove_origin_and_behavior
    resp = cloudfront_client.get_distribution({ id: distribution_id })
    etag = resp.etag
    distr = resp.distribution

    return unless distr.distribution_config.origins.items.any? { |origin| origin.id == origin_endpoint_name }
    new_origins = distr.distribution_config.origins.items.reject { |origin| origin.id == origin_endpoint_name }
    distr.distribution_config.origins.quantity -= 1
    distr.distribution_config.origins.items = new_origins

    return unless distr.distribution_config.cache_behaviors.items.any? { |behavior| behavior.target_origin_id == origin_endpoint_name }
    new_cache_behaviors = distr.distribution_config.cache_behaviors.items.reject { |behavior| behavior.target_origin_id == origin_endpoint_name }
    distr.distribution_config.cache_behaviors.quantity -= 1
    distr.distribution_config.cache_behaviors.items = new_cache_behaviors


    cloudfront_client.update_distribution({
                                            id: distribution_id,
                                             if_match: etag,
                                             distribution_config: distr.distribution_config
                                          })
  end

  def add_origin_and_behavior
    resp = cloudfront_client.get_distribution({ id: distribution_id })
    etag = resp.etag
    distr = resp.distribution

    new_origin = {
      id: origin_endpoint_name,
      domain_name: URI.parse(aws_resource.low_latency_hls_manifests[0].url).host,
      origin_path: '',
      custom_headers: {
        quantity: 0
      },
      custom_origin_config: {
        http_port: 80,
        https_port: 443,
        origin_protocol_policy: 'https-only',
        origin_ssl_protocols: {
          quantity: 1,
          items: ['TLSv1.2']
        },
        origin_read_timeout: 30,
        origin_keepalive_timeout: 5
      }
    }

    new_cache_behavior = {
      path_pattern: "/out/v1/#{origin_endpoint_name}/*",
      target_origin_id: origin_endpoint_name.to_s,
      trusted_signers: {
        enabled: false,
        quantity: 0
      },
      trusted_key_groups: {
        enabled: false,
        quantity: 0
      },
      viewer_protocol_policy: 'https-only',
      allowed_methods: {
        quantity: 2,
        items: %w[HEAD GET],
        cached_methods: {
          quantity: 2,
          items: %w[HEAD GET]
        }
      },
      smooth_streaming: false,
      compress: true,
      lambda_function_associations: {
        quantity: 0
      },
      function_associations: {
        quantity: 0
      },
      field_level_encryption_id: '',
      cache_policy_id: cache_policy.id
    }

    new_origins = distr.distribution_config.origins.items << new_origin
    distr.distribution_config.origins.quantity += 1
    distr.distribution_config.origins.items = new_origins

    new_cache_behaviors = distr.distribution_config.cache_behaviors.items << new_cache_behavior
    distr.distribution_config.cache_behaviors.quantity += 1
    distr.distribution_config.cache_behaviors.items = new_cache_behaviors

    cloudfront_client.update_distribution({
                                            id: distribution_id,
                                             if_match: etag,
                                             distribution_config: distr.distribution_config
                                          })
  end

  def cache_policy
    marker = nil
    cache_policies = []
    loop do
      resp = cloudfront_client.list_cache_policies({ type: 'managed', max_items: 1, marker: })
      cache_policies.concat(resp.cache_policy_list.items)
      break unless resp.cache_policy_list.next_marker
      marker = resp.cache_policy_list.next_marker
    end

    cache_policies.find { |policy| policy.cache_policy.cache_policy_config.name == 'Managed-Elemental-MediaPackage' }.cache_policy
  end
end
