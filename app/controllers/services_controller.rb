class ServicesController < ApplicationController

  # Redirects to the page in the service that allows the user to grant
  # permissions to allow the data.
  def link
    redirect_to current_service.link
  end

  # The page that the service redirects to to complete the transation.
  def connect
    service = current_service.create_with_code(params[:code], User.first)
    service.refresh!

    redirect_to account_path
  end

  def destroy
  end

  private

  def current_service
    services = {
      'jawbone' => JawboneUpService,
      'foursquare' => FoursquareService,
      'strava' => StravaService
    }

    @current_service = services[params[:service]]
    @current_service
  end
end
