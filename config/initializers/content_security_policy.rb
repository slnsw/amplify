Rails.application.config.content_security_policy do |policy|
  policy.default_src  :self
  policy.font_src     :self,
                      'https://fonts.googleapis.com', 
                      'https://use.fontawesome.com',
                      'https://fonts.gstatic.com',
                      'https://maxcdn.bootstrapcdn.com'
  policy.img_src      :self,
                      :data,
                      'https://*.google-analytics.com',
                      'https://*.analytics.google.com',
                      'https://*.googletagmanager.com',
                      'https://*.g.doubleclick.net',
                      'https://*.google.com',
                      'https://*.google.com.au',
                      'https://fonts.gstatic.com',
                      'https://graph.facebook.com',
                      'https://*.twitter.com',
                      'https://slnsw-amplify.s3.amazonaws.com',
                      'https://slnsw-amplify-staging.s3.amazonaws.com',
                      'https://s3.amazonaws.com',
                      'https://*.googleusercontent.com',
                      'http://graph.facebook.com',
                      'https://scontent.fcbr1-1.fna.fbcdn.net',
                      'https://*.google.de',
                      'https://*.google.com.mt',
                      'https://*.google.com.co',
                      'https://*.google.co.nz',
                      'https://*.google.co.kr',
                      'https://*.google.com.hk',
                      'https://*.google.co.uk',
                      'https://*.google.com.my',
                      'https://*.google.ru',
                      'https://www.google.fr'

  policy.object_src   :none
  policy.media_src    :self, 
                      'https://s3.amazonaws.com',
                      'https://slnsw-amplify-staging.s3.amazonaws.com',
                      'https://slnsw-amplify.s3.amazonaws.com',
                      'https://scontent.fcbr1-1.fna.fbcdn.net'
  policy.script_src   :self,
                      'https://*.googletagmanager.com',
                      'https://*.google-analytics.com',
                      'https://*.analytics.google.com',
                      'https://*.g.doubleclick.net',
                      'https://*.google.com',
                      'https://*.google.com.au',
                      'https://connect.facebook.net',
                      'https://platform.twitter.com',
                      'https://cdnjs.cloudflare.com',
                      :unsafe_inline,
                      :unsafe_eval

  policy.style_src    :self,
                      'https://fonts.googleapis.com', 
                      'https://use.fontawesome.com',
                      'https://maxcdn.bootstrapcdn.com',
                      :unsafe_inline

  if Rails.env.development?
    policy.connect_src :self, :https, 'http://localhost:3000', 'ws://localhost:3000'
  else
    policy.connect_src :self, :https
  end

  policy.frame_src    :self,
                      'https://td.doubleclick.net',
                      'https://platform.twitter.com',
                      'https://*.facebook.com',
                      'https://*.googletagmanager.com'


  policy.report_uri "/csp-violation-report-endpoint"
end

# Toggle report-only mode
Rails.application.config.content_security_policy_report_only = true
