class Admin::SettingsController < ApplicationController
  before_filter :admin_login_required
  layout "admin"

  def index
    @setting = Setting.find(:first) || Setting.create
  end

  def update
     @setting = Setting.find(params[:id])

    @setting.wine_pdf.destroy if @setting.wine_pdf && !params[:wine_pdf].blank?
    @setting.build_wine_pdf(params[:wine_pdf]) unless params[:wine_pdf].blank?

    @setting.home_image_1.destroy if @setting.home_image_1 && !params[:home_image_1].blank?
    @setting.build_home_image_1(:image_file => params[:home_image_1]) unless params[:home_image_1].blank?

    @setting.home_image_2.destroy if @setting.home_image_2 && !params[:home_image_2].blank?
    @setting.build_home_image_2(:image_file => params[:home_image_2]) unless params[:home_image_2].blank?

    @setting.home_image_3.destroy if @setting.home_image_3 && !params[:home_image_3].blank?
    @setting.build_home_image_3(:image_file => params[:home_image_3]) unless params[:home_image_3].blank?

    @setting.home_image_4.destroy if @setting.home_image_4 && !params[:home_image_4].blank?
    @setting.build_home_image_4(:image_file => params[:home_image_4]) unless params[:home_image_4].blank?

    @setting.home_image_5.destroy if @setting.home_image_5 && !params[:home_image_5].blank?
    @setting.build_home_image_5(:image_file => params[:home_image_5]) unless params[:home_image_5].blank?

    if @setting.update_attributes(params[:setting])
      flash[:notice] = "Setting correctly updated!"
    else
      flash[:notice] = @setting.show_errors
    end

    redirect_to :action => :index
  end
end

