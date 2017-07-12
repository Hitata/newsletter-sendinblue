require 'open-uri'
require 'digest'
require 'json'

class HomeController < ApplicationController
  BASE_URL = "https://justa.io"
  JOB_URL = BASE_URL + "/v1/jobs/:id"
  ASSET_URL = "https://d1v8colmz0r37h.cloudfront.net"

  def index
    @form_input = []
    @latest = []
    if params[:get_latest] == "get_info"
      @latest = scrape_latest
    end
  end

  def get_info
    @subject = info_params[:subject]
    @fids = info_params[:featured_job_ids].split(/,/).map(&:strip)
    if @fids.empty?
      flash[:error_featured_job_ids] = "Please type in a usuable Featured Job ID"
    end
    @ids = info_params[:job_ids].split(/,/).map!(&:strip)
    if @ids.empty?
      flash[:error_job_ids] = "Please type in a usuable Job ID"
    end

    @scheduled_at = info_params[:scheduled_at]

    @featured_jobs = @fids.map do |id|
      job = api_job(id)
      if job.empty?
        flash[:error_featured_job_ids] = "<a href='#{JOB_URL.gsub(/:id/, id)}'>Job ##{id}</a> is not found. Please find a usuable ID".html_safe
        break
      end
      job
    end

    @jobs = @ids.map do |id|
      job = api_job(id)
      if job.empty?
        flash[:error_job_ids] = "<a href='#{JOB_URL.gsub(/:id/, id)}'>Job ##{id}</a> is not found. Please find a usuable ID".html_safe
        break
      end
      job
    end

    if flash.present?
      @latest = []
      @form_input = info_params
      render :index
    end

    # Check according to hidden field date_id  
    @date_id = info_params[:date_id]
    @campaign = Campaign.find_by(date_id: @date_id)
    @campaign = Campaign.new unless @campaign.present?
    
    @campaign.date_id = @date_id
    @campaign.subject = @subject
    @campaign.scheduled_at = @scheduled_at
    @campaign.save

    @featured_jobs.each do |job|
      post = @campaign.posts.find_by(entry_id: job[:id])
      post = @campaign.posts.new unless post.present?

      post.title = job[:title]
      post.logo_url = job[:logo]
      post.company_name = job[:company]
      post.salary = job[:salary]
      post.entry_id = job[:id]
      post.location = job[:location]
      post.featured = 1
      post.save
    end

    @jobs.each do |job|
      post = @campaign.posts.find_by(entry_id: job[:id])
      post = @campaign.posts.new unless post.present?

      post.title = job[:title]
      post.logo_url = job[:logo]
      post.company_name = job[:company]
      post.salary = job[:salary]
      post.entry_id = job[:id]
      post.location = job[:location]
      post.featured = 0
      post.save
    end

    redirect_to @campaign

    # params[:engineering].reject! { |id| id.to_i <= 0 }
    # params[:business].reject! { |id| id.to_i <= 0 }

    # if params[:engineering].length != 3 || params[:business].length != 3
    #   flash[:alert] = 'Please fill out all 6 job IDs :)'
    #   render :index
    # end

    # if params[:commit].include? 'Japanese'
    #   @lang = :ja
    # else
    #   @lang = :en
    # end

    # @engineering, @business = [], []

    # params[:engineering].each do |id|
    #   @engineering << scrape_job(id, @lang)
    # end

    # params[:business].each do |id|
    #   @business << scrape_job(id, @lang)
    # end
  end

  def generate
    if params[:commit] == 'Preview'
      # render "email.#{params[:lang]}"
      render "new_email.en"
    else
      template = IO.read("app/views/home/email.#{params[:lang].to_s}.html.erb")
      erb = ERB.new(template)
      @html = erb.result(binding)
    end
  end

  private

  def info_params
    params.permit(
      :date_id,
      :subject,
      :featured_job_ids,
      :job_ids,
      :scheduled_at
      )
  end

  def api_job(id)
    url = JOB_URL.gsub(/:id/, id)
    res = JSON.parse open(url).read
    if res.empty?
      return res
    end

    {}.tap do |job|
      job[:id] = res[0]['id']
      job[:title] = res[0]['title_en']
      job[:company] = res[0]['company']['name']
      job[:location] = res[0]['company']['office_location']
      job[:logo] = ASSET_URL + res[0]['company']['logo']['url']
      job[:salary] = "Negotiable"
      if res[0]['show_salary'] == 1
        job[:salary] = "#{res[0]['salary_min']}¥ - #{res[0]['salary_max']}¥/monthly"
      end
      job[:url] = url
    end
  end

  def scrape_job(id, lang)
    lang = lang.to_s
    url = JOB_URL.gsub(/:lang/, lang).gsub(/:id/, id)
    hash = Digest::MD5.hexdigest "somethingspecial#{id}"
    result = {url: url}
    begin
      page = Nokogiri::HTML open(url + "?k=" + hash)
      result[:data] = {}.tap do |job|
        job[:id] = id
        job[:lang] = lang
        job[:title] = page.css('.job__title').text
        job[:company] = page.css('.job__company').text
        job[:logo] = page.css('.logo__img')[0]['src']
      end
    rescue Exception => e
      result[:data] = {}
    end

    result
  end

  def scrape_latest
    hash = Digest::MD5.hexdigest "dudeswhereismycar#{rand(9)}"
    url = BASE_URL + "/jobs" + "?k=" + hash
    page = Nokogiri::HTML open(url)
    list = page.css('li.job.job--list.group')
    
    list.map do |one|
      {
        logo: one.css('img.logo__img')[0]['src'],
        title: one.css('a.job__title').text,
        company: one.css('a.job__company').text,
        location: one.css('.job__type.hide-for-small').text,
        url: one.css('a.job__title')[0]['href'],
        id: one.css('a.job__title')[0]['href'][/[0-9]*$/],
      }
    end
  end
end
