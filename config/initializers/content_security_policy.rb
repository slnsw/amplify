Rails.application.config.content_security_policy do |policy|
  policy.default_src  :self, :https
  policy.font_src     :self, :https, :data, 'chrome-extension:'
  policy.img_src      :self, 'blob:', 'data:',
                      'https://*.google-analytics.com',
                      'https://*.analytics.google.com',
                      'https://*.googletagmanager.com',
                      'https://*.g.doubleclick.net',
                      'https://*.google.com',
                      'https://*.google.com.au',
                      'https://graph.facebook.com',
                      'http://graph.facebook.com', # Allow http for Facebook images
                      :https,
                      :data

  policy.object_src   :none

  policy.script_src   :self,
                      :https,
                      'https://*.googletagmanager.com',
                      'https://*.google-analytics.com',
                      'https://*.analytics.google.com',
                      'https://*.g.doubleclick.net',
                      'https://*.google.com',
                      'https://*.google.com.au',
                      'https://connect.facebook.net',
                      'https://platform.twitter.com',
                      :unsafe_inline,
                      :unsafe_eval

  policy.style_src    :self,
                      :https,
                      :unsafe_inline

  policy.connect_src  :self,
                      :https,
                      'http://localhost:3000',
                      'ws://localhost:3000'

  policy.frame_src    :self,
                      :https,
                      'https://td.doubleclick.net'

  policy.report_uri "/csp-violation-report-endpoint"
end

# Toggle report-only mode
Rails.application.config.content_security_policy_report_only = true
