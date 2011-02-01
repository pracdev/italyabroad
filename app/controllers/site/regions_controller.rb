class Site::RegionsController < ApplicationController
  layout 'site'

  def index
    @regions = Region.find(:all,:order=>'name asc').paginate(:page => params[:page], :per_page => 10)
    @regions_all = Region.find(:all,:order=>'name asc')

    respond_to do |format|
      format.html
    end
  end

  def show
    @region = Region.find(params[:id])

    respond_to do |format|
      format.html
    end
  end
end

