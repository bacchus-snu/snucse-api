class Api::V1::ApiController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
  extend ParameterValidator
  before_action :check_api_key, :check_user_level

  def check_api_key
    authenticate_or_request_with_http_token do |token, options|
      api_key = ApiKey.where(access_token: token).first
      # A revoked token is an invalid credential; 401 tells the client to sign in again.
      if api_key.nil? or api_key.revoked?
        render_unauthorized and return
      end
      @user = api_key.user rescue nil
    end
  end

  def check_user_level
    render json: {}, status: :forbidden unless @user and @user.active?
  end

  def render_unauthorized
    render json: {}, status: :unauthorized
  end

  rescue_from Apipie::ParamMissing do |exception|
    json = {
      exception.param.name => "required"
    }
    render status: :bad_request, json: {
      errors: json
    }
  end

  rescue_from Apipie::ParamMultipleMissing do |exception|
    errors = exception.params.to_h { |param| [param.name, "required"] }
    render status: :bad_request, json: { errors: errors }
  end

  rescue_from Apipie::ParamInvalid do |exception|
    json = {
      exception.param.to_s => "invalid"
    }
    render status: :bad_request, json: {
      errors: json
    }
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render status: :not_found, json: {}
  end

  rescue_from ActiveRecord::RecordInvalid do |exception|
    render status: :bad_request, json: {
      errors: exception.record.errors.messages
    }
  end
end
