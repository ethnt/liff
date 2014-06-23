class UsersController < ApplicationController
  def show
    if params[:year] && params[:month] && params[:day]
      @view_date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    else
      @view_date = Date.today
    end

    if @view_date
      @reports = view_user.reports_for_date(@view_date).to_a
    else
      @reports = view_user.reports_for_date.to_a
    end

    @nav = {
      prev: false,
      next: false
    }

    if !view_user.reports_for_date(@view_date - 1.day).to_a.nil?
      @nav[:prev] = @view_date - 1.day
    end

    if !view_user.reports_for_date(@view_date + 1.day).to_a.nil?
      @nav[:next] = @view_date + 1.day
    end
  end

  def refresh
    user = User.find(params[:id])
    user.refresh!

    redirect_to params[:redirect_to]
  end

  private

  def view_user
    @view_user = User.where(username: params[:username]).first
    @view_user
  end
end
