# NOTE: since we are moving the frontend from backbone to rails, it will be easier to
#       have a seperate base controller for standard rails views
#
#       This controller can be deprecated and the code can be moved to ApplicationController
#       once the backbone frontend is 100% removed.
class AmplifyBaseController < ActionController::Base
  include Authentication

  before_action :authenticate_user!
end
