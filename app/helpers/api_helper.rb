module ApiHelper
  BASE_URL = "https://justa.io"
  JOB_URL = BASE_URL + "/v1/jobs/:id"
  ASSET_URL = "https://d1v8colmz0r37h.cloudfront.net"

  def get_test
    ASSET_URL
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
      if res[0]['title_en'].empty?
        job[:title] = res[0]['title_ja']
      end
      job[:company] = res[0]['company']['name']

      state = res[0]['address']['state']
      if res[0]['address']['state'].empty?
        state = res[0]['address']['state_jp']
      end
      country_code = res[0]['company']['country']
      if state.blank? or country_code.blank? 
        job[:location] = "Tokyo, Japan"
      else
        job[:location] = state + "," + I18n.t("address.country.#{country_code.to_s}")
      end
      
      job[:logo] = ASSET_URL + res[0]['company']['logo']['url']
      job[:salary] = "Negotiable"
      if res[0]['show_salary'] == 1
        job[:salary] = "#{res[0]['salary_min']}¥ - #{res[0]['salary_max']}¥/monthly"
      end
      job[:url] = url
    end
  end
end
