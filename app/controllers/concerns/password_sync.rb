module PasswordSync
  extend ActiveSupport::Concern

  ID_HOST = "id.snucse.org".freeze
  LEGACY_LOGIN_PATH = "/Authentication/Login.aspx".freeze

  def sync_registration(username, name, birthday, bs_number, email, phone_number)
    year = birthday[0..3]
    month = birthday[5..6]
    date = birthday[8..9]
    id_http.post("/Account/JoinSubmit.aspx", {terms: "on", consent: "on", name: name, birth_year: year, birth_month: month, birth_date: date, account: username, bs_number: bs_number, ms_number: nil, phd_number: nil, graduate_year: nil, graduate_month: nil, email: email, phone: phone_number}.to_query, form_headers)
  end

  def check_password(username, password)
    if Rails.env.production?
      id_password_valid?(username, password)
    else
      User.find_by(username: username)&.authenticate(password).present?
    end
  end

  # The legacy login answers 302 on success and 200 on failure. Only 302 counts:
  # any other status, a network error or a timeout must deny.
  def id_password_valid?(username, password)
    legacy_login(username, password).is_a?(Net::HTTPFound)
  rescue StandardError => e
    logger&.error("id login check failed: #{e.class}")
    false
  end

  def sync_password(username, password, new_password)
    resp = legacy_login(username, password)
    return unless resp.is_a?(Net::HTTPFound)
    http = id_http
    resp2 = http.get("/User/ModifyPasswordForm.aspx?account=#{username}", {"Cookie" => resp["set-cookie"]})
    doc = Nokogiri::HTML(resp2.body)
    uid = doc.css("input[name=uid]").attr("value").value
    http.post("/User/ModifyPasswordSubmit.aspx", {uid: uid, current_password: password, new_password: new_password, new_password_confirm: new_password}.to_query, form_headers.merge("Cookie" => resp["set-cookie"]))
  end

  private

  def legacy_login(username, password)
    id_http.post(LEGACY_LOGIN_PATH, {login_type: "member_login", referrer: nil, redirect_mode: "keep", secure: "on", member_account: username, member_password: password}.to_query, form_headers)
  end

  # Net::HTTP no longer supplies a default Content-Type for request bodies.
  def form_headers
    {"Content-Type" => "application/x-www-form-urlencoded"}
  end

  def id_http
    http = Net::HTTP.new(ID_HOST, 443)
    http.use_ssl = true
    http.open_timeout = 5
    http.read_timeout = 10
    http
  end
end
