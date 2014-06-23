class LiffController < ApplicationController
  def index
    if current_user
      redirect_to user_path(username: current_user.username)
    end
  end
end
