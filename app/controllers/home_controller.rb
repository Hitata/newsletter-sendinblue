require 'open-uri'
require 'digest'

class HomeController < ApplicationController
  BASE_URL = "https://justa.io"
  JOB_URL = BASE_URL + "/:lang/jobs/:id"

  def index
    @latest = []
    if params[:get_latest] == "get_info"
      @latest = scrape_latest
    end
  end

  def get_info
    params[:engineering].reject! { |id| id.to_i <= 0 }
    params[:business].reject! { |id| id.to_i <= 0 }

    if params[:engineering].length != 3 || params[:business].length != 3
      flash[:alert] = 'Please fill out all 6 job IDs :)'
      render :index
    end

    if params[:commit].include? 'Japanese'
      @lang = :ja
    else
      @lang = :en
    end

    @engineering, @business = [], []

    params[:engineering].each do |id|
      @engineering << scrape_job(id, @lang)
    end

    params[:business].each do |id|
      @business << scrape_job(id, @lang)
    end
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

  def scrape_job(id, lang)
    lang = lang.to_s
    url = JOB_URL.gsub(/:lang/, lang).gsub(/:id/, id)
    hash = Digest::MD5.hexdigest "somethingspecial#{id}"
    page = Nokogiri::HTML open(url + "?k=" + hash)

    {}.tap do |job|
      job[:id] = id
      job[:lang] = lang
      job[:title] = page.css('.job__title').text
      job[:company] = page.css('.job__company').text
      job[:logo] = page.css('.logo__img')[0]['src']
    end
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
