Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.script_src :self, :https
    policy.style_src :self, :https, :unsafe_inline
    policy.img_src :self, :https, :data, :blob
    policy.font_src :self, :https, :data
    policy.connect_src :self, :https, :wss
    policy.media_src :self, :https, :blob
    policy.object_src :none
    policy.base_uri :self
    policy.form_action :self, :https
  end
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]
  config.content_security_policy_nonce_auto = true
  # 外部プレイヤー等との互換性を確認してから強制へ切り替える。
  config.content_security_policy_report_only = true
end
