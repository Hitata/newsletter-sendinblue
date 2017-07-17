class CampaignsController < ApplicationController
  layout "preview", only: [:preview]

  def index
    @list = Campaign.all.order(id: :desc)
  end

  def show
    @campaign = Campaign.find_by(id: params[:id])
  end

  def preview
    @campaign = Campaign.find_by(id: params[:id])
  end

  def code
    @campaign = Campaign.find_by(id: params[:id])
    
    template = IO.read("app/views/campaigns/preview.html.erb")
    erb = ERB.new(template)
    @html = erb.result(binding)
  end

  def update
    @campaign = Campaign.find params[:id]

    respond_to do |format|
      if @campaign.update campaign_params
        # format.html { redirect_to(@campaign, :notice => 'Campaign was successfully updated.') }
        format.json { respond_with_bip(@campaign) }
      # else
      end
    end
  end

  private

  def campaign_params
    params.require(:campaign)
      .permit(
        :subject,
      )
  end
end