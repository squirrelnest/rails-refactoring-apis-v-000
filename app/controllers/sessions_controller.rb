class SessionsController < ApplicationController

  skip_before_action :authenticate_user, only: :create

  def create
    github = GithubService::authenticate!(params[:code], session)
    session[:username] = github.get_username
    redirect_to '/'
  end

end
