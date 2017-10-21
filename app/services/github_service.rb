class GithubService

  attr_reader :access_token
  CLIENT_ID = ENV['GITHUB_CLIENT_ID']
  CLIENT_SECRET = ENV['GITHUB_CLIENT_SECRET']

  def initialize(session)
    @access_token = session[:token]
  end

  def self.authenticate!(code, session)
    response = Faraday.post "https://github.com/login/oauth/access_token",
        {client_id: CLIENT_ID, client_secret: CLIENT_SECRET, code: code},
        {'Accept' => 'application/json'}
    access_hash = JSON.parse(response.body)
    @access_token = access_hash["access_token"]
    session[:token] = @access_token
    return self
  end

  def get_username
    user_response = Faraday.get "https://api.github.com/user", {}, {'Authorization' => "token #{self.access_token}", 'Accept' => 'application/json'}
    user_json = JSON.parse(user_response.body)
    user_json["login"]
  end

  def get_repos
    response = Faraday.get "https://api.github.com/user/repos", {}, {'Authorization' => "token #{self.access_token}", 'Accept' => 'application/json'}
    repos_array = JSON.parse(response.body)
    repos_array.collect { |repo| GithubRepo.new(repo) }
  end

  def create_repo(name)
    Faraday.post "https://api.github.com/user/repos", {name: name}.to_json, {'Authorization' => "token #{self.access_token}", 'Accept' => 'application/json'}
  end

end
