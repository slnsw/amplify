# frozen_string_literal: true

# This app is a Rails API implmemenation
# the ApplicationController inherits from ActionController::API
# The Admin Portal features use erb views and require access to
# the protect_from_forgery methods provided by ActionController::Base
module Admin
  class ApplicationController < ActionController::Base
    include Authentication
    before_action :authenticate_admin!
    layout 'cms'
  end
end
