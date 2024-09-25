csp_log_path = Rails.root.join('log', 'csp_violations.log')

CSP_LOGGER = Logger.new(csp_log_path)
CSP_LOGGER.level = Logger::INFO
