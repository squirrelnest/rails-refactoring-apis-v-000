class GithubService

  attr_reader :access_token
  CLIENT_ID = ENV['GITHUB_CLIENT_ID']
  CLIENT_SECRET = ENV['GITHUB_CLIENT_SECRET']

  def initialize(foo = {})
    @access_token = foo[:access_token]
  end

  def authenticate!(foo, bar, code)
    response = Faraday.post("https://github.com/login/oauth/access_token") do |req|
      req.body = {client_id: CLIENT_ID, client_secret: CLIENT_SECRET, code: code}
      req.headers = {'Accept' => 'application/json'}
    end
    access_hash = JSON.parse(response.body)
    @access_token = access_hash["access_token"]
  end

  def get_username
    user_response = Faraday.get(
      "https://api.github.com/user",
     {},
     {'Authorization' => "token #{self.access_token}", 'Accept' => 'application/json'}
    )
    user_json = JSON.parse(user_response.body)
    user_json["login"]
  end

  def get_repos
    response = Faraday.get(
      "https://api.github.com/user/repos",
     {},
     {'Authorization' => "token #{self.access_token}", 'Accept' => 'application/json'}
    )
    repos_array = JSON.parse(response.body)
    repos_array.map { |repo| GithubRepo.new(repo) }
  end

  def create_repo(name)
    Faraday.post "https://api.github.com/user/repos", {name: name}.to_json, {'Authorization' => "token #{self.access_token}", 'Accept' => 'application/json'}
  end

end
