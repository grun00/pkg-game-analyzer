class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM", "no-reply@whiplashgamestats.com")
  layout "mailer"
end
