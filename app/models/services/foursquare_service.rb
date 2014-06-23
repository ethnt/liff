class FoursquareService < Service
  field :access_token, type: String

  def client
    Foursquare2::Client.new(oauth_token: self.access_token, api_version: '20140622')
  end

  def checkins_for_date(date = Date.today)
    date = date.to_time.utc

    after_timestamp = date.to_i
    before_timestamp = ((date + 1.day) - 1.second).to_i

    self.client.user_checkins(
      afterTimestamp: after_timestamp,
      beforeTimestamp: before_timestamp
    )
  end

  def refresh!
    recent = self.client.user_checkins['items']

    recent.each do |checkin|
      date = Time.at(checkin['createdAt']).to_date

      existing_report = self.reports.where(date: date).first

      if existing_report
        unless existing_report.checkins.include?(checkin)
          existing_report.checkins << checkin
          existing_report.save
        end
      else
        new_report = FoursquareReport.new(
          checkins: [checkin],
          date: date
        )

        new_report.user = self.user

        new_report.save

        self.reports << new_report
        self.save
      end
    end
  end

  class << self
    def link
      "https://foursquare.com/oauth2/authenticate?client_id=#{ENV['FOURSQUARE_CLIENT_ID']}&response_type=code&redirect_uri=#{ENV['FOURSQUARE_REDIRECT_URI']}"
    end

    def create_with_code(code, user)
      res = request_token!(code)

      if res['access_token']
        foursquare = FoursquareService.new(
          access_token: res['access_token']
        )

        foursquare.save

        user.services << foursquare
        user.save

        foursquare
      end
    end

    def request_token!(code)
      res = Faraday.get(
        'https://foursquare.com/oauth2/access_token',
        {
          client_id: ENV['FOURSQUARE_CLIENT_ID'],
          client_secret: ENV['FOURSQUARE_CLIENT_SECRET'],
          grant_type: 'authorization_code',
          redirect_uri: ENV['FOURSQUARE_REDIRECT_URI'],
          code: code
        }
      )

      Oj.load(res.body)
    end
  end
end
