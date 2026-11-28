require "minitest/autorun"
require "active_support/all"
require "net/http"
require_relative "../../../app/controllers/concerns/password_sync"

class PasswordSyncTest < Minitest::Test
  class FakeHTTP
    attr_reader :requests

    def initialize(outcome)
      @outcome = outcome
      @requests = []
    end

    def post(path, body, headers)
      @requests << {path: path, body: body, headers: headers}
      raise @outcome if @outcome.is_a?(Exception)
      @outcome
    end
  end

  class Checker
    include PasswordSync

    def initialize(http)
      @http = http
    end

    def logger
      nil
    end

    private

    def id_http
      @http
    end
  end

  def response(klass, code)
    klass.new("1.1", code, "")
  end

  def valid?(outcome)
    http = FakeHTTP.new(outcome)
    [Checker.new(http).id_password_valid?("user", "pw"), http]
  end

  def test_only_302_is_success
    assert_equal true, valid?(response(Net::HTTPFound, "302")).first
  end

  def test_every_other_status_denies
    {
      "200" => Net::HTTPOK, "301" => Net::HTTPMovedPermanently, "303" => Net::HTTPSeeOther,
      "400" => Net::HTTPBadRequest, "401" => Net::HTTPUnauthorized, "404" => Net::HTTPNotFound,
      "429" => Net::HTTPTooManyRequests, "500" => Net::HTTPInternalServerError,
      "502" => Net::HTTPBadGateway, "503" => Net::HTTPServiceUnavailable, "504" => Net::HTTPGatewayTimeout,
    }.each do |code, klass|
      assert_equal false, valid?(response(klass, code)).first, "status #{code} must deny"
    end
  end

  def test_network_failures_deny
    [Net::OpenTimeout.new, Net::ReadTimeout.new, Errno::ECONNREFUSED.new, OpenSSL::SSL::SSLError.new, SocketError.new].each do |error|
      assert_equal false, valid?(error).first, "#{error.class} must deny"
    end
  end

  def test_sends_form_content_type_and_credentials
    _, http = valid?(response(Net::HTTPOK, "200"))
    request = http.requests.fetch(0)
    assert_equal PasswordSync::LEGACY_LOGIN_PATH, request[:path]
    assert_equal "application/x-www-form-urlencoded", request[:headers]["Content-Type"]
    params = URI.decode_www_form(request[:body]).to_h
    assert_equal "user", params["member_account"]
    assert_equal "pw", params["member_password"]
  end
end
