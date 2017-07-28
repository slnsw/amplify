class Admin::CmsController < Admin::ApplicationController  
  def show
    @collection = Collection.all
  end
end
