class Api::V1::UsersController < Api::V1::ApiController
  include OidcClient
  skip_before_action :check_api_key, only: :oidc_sign_in
  skip_before_action :check_user_level
  api! "id.snucse.org에서 발급한 authorization code로 인증 후 access token을 전달한다. 스누씨 계정이 없으면 id.snucse.org의 정보로 계정을 만든다."
  param :code, String, desc: "id.snucse.org에서 발급한 authorization code", required: true, empty: false
  param :codeVerifier, String, desc: "PKCE code verifier", required: true, empty: false
  param :privacyConsent, TrueClass, desc: "개인정보 수집, 이용 및 처리 동의 여부, 계정을 만들 때 필요", required: false
  error code: 400, desc: "authorization code가 유효하지 않은 경우"
  error code: 403, desc: "id.snucse.org 계정이 스누씨 이용 권한이 있는 그룹에 속하지 않은 경우"
  error code: 404, desc: "스누씨 계정이 없고 개인정보 수집, 이용 및 처리에 동의하지 않은 경우"
  error code: 409, desc: "스누씨 계정이 없고 계정명이 이미 만들어진 프로필 아이디 또는 예약어와 같은 경우"
  error code: 419, desc: "가입 승인이 되지 않은 계정인 경우"
  example <<-EOS
  {
    "accessToken": "abcdef0123456789abcdef"
  }
  EOS
  def oidc_sign_in
    userinfo = fetch_userinfo(params[:code], params[:codeVerifier])
    if userinfo.nil?
      render status: :bad_request, json: {} and return
    end
    if (userinfo["groups"] & Rails.configuration.x.oidc["permitted_groups"]).empty?
      render status: :forbidden, json: {} and return
    end
    user = User.where(username: userinfo["username"]).find { |u| u.username == userinfo["username"] }
    if user.nil?
      if Profile.where(sid: userinfo["username"]).any? or ReservedWord.where(word: userinfo["username"]).any?
        render status: :conflict, json: {} and return
      end
      unless params[:privacyConsent].to_s == "true"
        render status: :not_found, json: {} and return
      end
      user = User.new(
        username: userinfo["username"],
        name: userinfo["name"]
      )
      user.set_information(
        bs_number: userinfo["student_id"].presence,
        email: userinfo["email"],
        is_email_public: true,
        is_phone_number_public: true
      )
      user.save!
    end
    if user.level == 0
      profile = Profile.create(sid: user.username, name: user.name, profile_type: 2, admin_id: user.id, description: "", rendering_mode: 1)
      [4538, 4760, 4761, 4925, 4759].each do |pid|
        Follow.create(user_id: user.id, profile_id: pid)
      end
      Follow.create(user_id: user.id, profile_id: profile.id)
      user.update_attributes(level: 2)
    end
    if user.valid_level?
      api_key = ApiKey.create(
        user_id: user.id
      )
      render json: {
        accessToken: api_key.access_token
      }
    else
      render status: 419, json: {}
    end
  end

  api! "로그인한 사용자의 정보를 전달한다."
  example <<-EOS
  {
    "id": 1,
    "level": 2,
    "name": "사용자",
    "username": "username",
    "profileImageUri": "https://www.snucse.org/files/profile_images/default",
    "renderingMode": "text"
  }
  EOS
  def me
  end

  api! "로그인한 사용자의 정보를 변경한다."
  param :birthday, /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/, desc: "생년월일", required: false
  param :bsNumber, /^[0-9]{4}-[0-9]{5}$/, desc: "학번", required: false
  param :email, String, desc: "이메일", required: false
  param :phoneNumber, /^[0-9]{2,3}-[0-9]{3,4}-[0-9]{4}$/, desc: "전화번호", required: false
  param :isBirthdayPublic, TrueClass, desc: "생년월일 공개 여부", required: false
  param :isEmailPublic, TrueClass, desc: "이메일 공개 여부", required: false
  param :isPhoneNumberPublic, TrueClass, desc: "전화번호 공개 여부", required: false
  def update
    @user.birthday = params[:birthday] if params[:birthday]
    @user.is_birthday_public = params[:isBirthdayPublic] if params[:isBirthdayPublic]
    is_email_public = if params[:isEmailPublic].nil? then nil else params[:isEmailPublic].to_s == "true" end
    is_phone_number_public = if params[:isPhoneNumberPublic].nil? then nil else params[:isPhoneNumberPublic].to_s == "true" end
    @user.set_information(
      bs_number: params[:bsNumber],
      email: params[:email],
      is_email_public: is_email_public,
      phone_number: params[:phoneNumber],
      is_phone_number_public: is_phone_number_public
    )
    @user.save
    render json: {}
  end

  api! "자신의 프로필 이미지를 업로드한다."
  param :image, File, desc: "프로필 이미지", required: true
  error code: 400, desc: "이미지 파일이 아닌 파일을 업로드한 경우"
  def upload_profile_image
    unless params[:image].content_type.start_with? "image"
      render json: {}, status: :bad_request and return
    end
    @user.update_attributes(
      profile_image: params[:image]
    )
    render json: {}
  end

  api! "자신의 프로필 이미지를 삭제한다."
  def destroy_profile_image
    @user.remove_profile_image = true
    @user.save
    render json: {}
  end

  api! "생일인 사용자의 목록을 전달한다."
  param :date, /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/, desc: "생일인 사람의 목록을 구하는 날짜, 기본값은 오늘", required: false
  def birthday
    # TODO: 음력 생일 고려하기
    date = params[:date].to_date rescue Date.today
    @users = User.where(is_birthday_public: true, is_birthday_lunar: false).where("MONTH(birthday) = ? and DAYOFMONTH(birthday) = ?", date.month, date.day)
  end
end
