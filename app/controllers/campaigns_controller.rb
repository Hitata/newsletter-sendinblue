class CampaignsController < ApplicationController

  def index
    @list = Campaign.all.order(id: :desc)
  end

  def show
    @campaign = Campaign.find_by(id: params[:id])
  end

  def preview
    @campaign = Campaign.find_by(id: params[:id])
  end
end