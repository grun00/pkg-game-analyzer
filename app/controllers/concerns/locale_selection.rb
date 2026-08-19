module LocaleSelection
  extend ActiveSupport::Concern

  included do
    before_action :switch_locale
  end

  private

  # Set the request locale up front via a before_action. This runs inside the
  # rescue_from wrapper, so error handlers see the localized value. Threads are
  # reused by Puma, but every request that includes this concern overwrites the
  # locale here, so no stale value can leak across requests.
  def switch_locale
    I18n.locale = locale_from_request
  end

  # Precedence: explicit ?locale= param, then Accept-Language header,
  # then the configured default. Only locales in available_locales are honored.
  def locale_from_request
    param_locale || header_locale || I18n.default_locale
  end

  def param_locale
    requested = params[:locale].to_s
    requested if available?(requested)
  end

  def header_locale
    return nil unless request.env.key?("HTTP_ACCEPT_LANGUAGE")

    http_accept_language.compatible_language_from(I18n.available_locales)
  end

  def available?(locale)
    locale.present? && I18n.available_locales.map(&:to_s).include?(locale)
  end
end
