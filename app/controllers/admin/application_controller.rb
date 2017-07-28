# This app is a Rails API implmemenation
# the ApplicationController inherits from ActionController::API
# The Admin CMS features use erb views and require access to
# the protect_from_forgery methods provided by ActionController::Base
class Admin::ApplicationController < ActionController::Base
  include Authentication
  before_filter :authenticate_admin!
  layout "cms"
end
