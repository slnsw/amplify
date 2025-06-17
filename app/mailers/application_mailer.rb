# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'web.development@sl.nsw.gov.au'
  layout 'mailer'
end
