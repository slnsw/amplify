Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data
  policy.object_src  :none
  policy.script_src  :self, :https, 'http://www.googletagmanager.com', :unsafe_inline, :unsafe_eval
  policy.style_src   :self, :https, :unsafe_inline
  policy.connect_src :self, :https, 'http://localhost:3000', 'ws://localhost:3000'

  # Specify URI for violation reports
  policy.report_uri "/csp-violation-report-endpoint"
end

Rails.application.config.content_security_policy_report_only = true
