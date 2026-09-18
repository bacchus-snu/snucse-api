module OidcClient
  extend ActiveSupport::Concern

  def fetch_userinfo(code, code_verifier)
    conf = Rails.configuration.x.oidc
    token_uri = URI("#{conf["issuer"]}/token")
    token_request = Net::HTTP::Post.new(token_uri)
    token_request.basic_auth(URI.encode_www_form_component(conf["client_id"]), URI.encode_www_form_component(conf["client_secret"]))
    token_request.set_form_data(grant_type: "authorization_code", code: code, redirect_uri: conf["redirect_uri"], code_verifier: code_verifier)
    token_response = Net::HTTP.start(token_uri.host, token_uri.port, use_ssl: token_uri.scheme == "https") do |http|
      http.request(token_request)
    end
    return nil unless token_response.is_a? Net::HTTPSuccess

    userinfo_uri = URI("#{conf["issuer"]}/me")
    userinfo_request = Net::HTTP::Get.new(userinfo_uri)
    userinfo_request["Authorization"] = "Bearer #{JSON.parse(token_response.body)["access_token"]}"
    userinfo_response = Net::HTTP.start(userinfo_uri.host, userinfo_uri.port, use_ssl: userinfo_uri.scheme == "https") do |http|
      http.request(userinfo_request)
    end
    userinfo_response.value
    JSON.parse(userinfo_response.body)
  end
end
