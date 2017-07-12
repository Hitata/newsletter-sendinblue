class PostsController < ApplicationController
  include ApiHelper

  def create
    @campaign = Campaign.find(params[:campaign_id])
    job = api_job(params[:job_id])
    @params = params

    if job.empty?
      id = params[:job_id]
      if params[:featured] == "true"
        flash[:alert] = "<a href='#{JOB_URL.gsub(/:id/, id)}'>Featured Job ##{id}</a> is not found. Please find a usuable ID".html_safe
      else
        flash[:notice] = "<a href='#{JOB_URL.gsub(/:id/, id)}'>Job ##{id}</a> is not found. Please find a usuable ID".html_safe
      end
    else
      post = @campaign.posts.find_by(entry_id: job[:id])
      post = @campaign.posts.new unless post.present?

      post.title = job[:title]
      post.logo_url = job[:logo]
      post.company_name = job[:company]
      post.salary = job[:salary]
      post.entry_id = job[:id]
      post.location = job[:location]
      post.featured = params[:featured]
      post.save
    end

    redirect_to @campaign
  end

  def destroy
    post = Post.find(params[:id])
    post.destroy

    redirect_to post.campaign
  end


end