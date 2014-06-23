class JawboneUpService < Service
  field :access_token, type: String
  field :refresh_token, type: String
  field :expiration_date, type: Date, default: (Time.now + 1.year)

  def client
    Jawbone::Client.new(self.access_token)
  end

  def refresh!
    refresh_steps!
    refresh_sleep!

    self.last_refresh = Time.now
    self.save
  end

  def refresh_steps!
    items = self.client.moves['data']['items']

    items.each do |day|
      date = Date.strptime(day['date'].to_s, '%Y%m%d')

      existing_report = self.reports.where(date: date).first

      if existing_report
        if day['details']['steps'] != existing_report.steps
          existing_report.steps = day['details']['steps']
          existing_report.save
        end
      else
        new_report = JawboneUpReport.new(
          steps: day['details']['steps'],
          date: date
        )

        new_report.user = self.user

        new_report.save

        self.reports << new_report
        self.save
      end
    end
  end

  def refresh_sleep!
    items = self.client.sleeps['data']['items']

    items.each do |day|
      date = Date.strptime(day['date'].to_s, '%Y%m%d')

      existing_report = self.reports.where(date: date).first

      time = day['details']['duration'] - day['details']['awake']

      if existing_report
        if existing_report.sleep != time
          existing_report.sleep = time
          existing_report.save
        end
      else
        new_report = JawboneUpReport.new(
          sleep: time,
          date: date
        )

        new_report.save

        self.reports << new_report
        self.save
      end
    end
  end

  def steps(date = Date.today)
    res = self.client.moves(date: date.strftime('%Y%m%d'))
    res['data']['items'][0]['details']['steps']
  end

  def sleeps(date = Date.today)
    res = self.client.sleeps(date: date.strftime('%Y%m%d'))
    res['data']['items'][0]['details']['duration']
  end

  class << self
    def link
      scopes = ['basic_read', 'extended_read', 'move_read', 'sleep_read', 'meal_read', 'weight_read', 'cardiac_read', 'generic_even_read']
      scopes = scopes.join('%20')

      return "https://jawbone.com/auth/oauth2/auth?response_type=code&client_id=#{ENV['JAWBONE_CLIENT_ID']}&scope=#{scopes}&redirect_uri=http://liff.dev/services/jawbone/connect"
    end

    def create_with_code(code, user)
      res = self.request_token!(code)

      if res['access_token']
        jawbone = JawboneUpService.new(
          access_token: res['access_token'],
          refresh_token: res['refresh_token']
        )

        jawbone.save

        user.services << jawbone
        user.save

        jawbone
      end
    end

    def request_token!(code)
      res = Faraday.get(
        'https://jawbone.com/auth/oauth2/token',
        {
          client_id: ENV['JAWBONE_CLIENT_ID'],
          client_secret: ENV['JAWBONE_CLIENT_SECRET'],
          grant_type: 'authorization_code',
          code: code
        }
      )

      Oj.load(res.body)
    end
  end
end
