class StravaService < Service
  field :access_token, type: String

  class << self
    def link
      "https://www.strava.com/oauth/authorize?client_id=#{ENV['STRAVA_CLIENT_ID']}&redirect_uri=#{ENV['STRAVA_REDIRECT_URI']}&response_type=code&approval_prompt=force"
    end

    def create_with_code(code, user)
      res = request_token!(code)

      if res['access_token']
        strava = StravaService.new(
          access_token: res['access_token']
        )

        strava.save

        user.services << strava
        user.save

        strava
      end
    end

    def request_token!(code)
      res = Faraday.get(
        'https://www.strava.com/oauth/token',
        {
          client_id: ENV['STRAVA_CLIENT_ID'],
          client_secret: ENV['STRAVA_CLIENT_SECRET'],
          code: code
        }
      )

      Oj.load(res.body)
    end
  end
end
