# frozen_string_literal: true

require 'base64'

class RefreshTokenError < StandardError; end

class TrophyHunter < Sequel::Model
  DEFAULT_TOKEN_EXPIRATION_TIME = 3500

  dataset_module do
    def active_hunters
      where(active: true).all
    end
  end

  # TODO: change method name to more appropriate one
  def full_authentication(sso_cookie)
    Psn::InitialAuthenticationService.call(self, sso_cookie)
  end

  def authenticate
    result = Psn::UpdateAccessTokenService.new(self).call
    raise RefreshTokenError, I18n.t(:refresh_token_error, scope: 'exceptions', hunter_name: name) if result.failure?

    result.access_token
  end

  def store_access_token(access_token)
    RedisDb.redis.setex("holy_rider:trophy_hunter:#{name}:access_token",
                        DEFAULT_TOKEN_EXPIRATION_TIME,
                        access_token)
    access_token
  end

  def activate
    update(active: true)
  end

  def deactivate
    update(active: false)
  end

  def geared_up?
    access_token.present?
  end

  def active?
    active
  end

  def access_token
    RedisDb.redis.get("holy_rider:trophy_hunter:#{name}:access_token")
  end
end
