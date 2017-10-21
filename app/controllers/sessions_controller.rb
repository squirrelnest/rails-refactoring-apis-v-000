class SessionsController < ApplicationController

  skip_before_action :authenticate_user, only: :create

  def create
    github = GithubService.new
    session[:token] = github.authenticate!('foo', 'bar', params[:code])
    session[:username] = github.get_username
    redirect_to '/'
  end

end
