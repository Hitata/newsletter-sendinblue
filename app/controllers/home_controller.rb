require 'open-uri'

class HomeController < ApplicationController
  BASE_URL = "https://justa.io"
  JOB_URL = BASE_URL + "/:lang/jobs/:id"

  def index
  end

  def get_info
    params[:engineering].reject! { |id| id.to_i <= 0 }
    params[:business].reject! { |id| id.to_i <= 0 }

    if params[:engineering].length != 3 || params[:business].length != 3
      flash[:alert] = 'Please fill out all 6 job IDs :)'
      render :index
    end

    @engineering, @business = [], []

    params[:engineering].each do |id|
      @engineering << scrape_job(id, :en)
    end

    params[:business].each do |id|
      @business << scrape_job(id, :en)
    end
  end

  def generate
    if params[:commit] == 'Preview'
      render :email
    else
      template = IO.read('app/views/home/email.html.erb')
      erb = ERB.new(template)
      @html = erb.result(binding)
    end
  end

  private

  def scrape_job(id, lang)
    lang = lang.to_s
    url = JOB_URL.gsub(/:lang/, lang).gsub(/:id/, id)
    page = Nokogiri::HTML open(url)

    {}.tap do |job|
      job[:id] = id
      job[:lang] = lang
      job[:title] = page.css('.job__title').text
      job[:company] = page.css('.job__company').text
      job[:logo] = BASE_URL + page.css('.logo__img')[0]['src']
    end
  end
end
