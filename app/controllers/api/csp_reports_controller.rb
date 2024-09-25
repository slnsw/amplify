class Api::CspReportsController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def create
    CSP_LOGGER.info("CSP Violation: #{request.body.read}")
    head :ok
  end

  private

  def report_params
    params.permit!
  end
end
