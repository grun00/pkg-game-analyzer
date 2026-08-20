class CreatorRequestMailer < ApplicationMailer
  # Recipient for new creator applications. Overridable via env for staging.
  ADMIN_RECIPIENT = ENV.fetch("CREATOR_REQUESTS_RECIPIENT", "whiplashgamelabs@gmail.com").freeze

  # Sent to the admin inbox whenever a user submits a new creator request.
  def submission_email
    @creator_request = params[:creator_request]
    @user = @creator_request.user
    mail(
      to: ADMIN_RECIPIENT,
      subject: I18n.t("creator_request_mailer.submission_email.subject", email: @user.email)
    )
  end

  # Sent to the applicant when an admin approves or rejects their request.
  def decision_email
    @creator_request = params[:creator_request]
    @user = @creator_request.user
    @approved = @creator_request.status_approved?
    mail(
      to: @user.email,
      subject: I18n.t("creator_request_mailer.decision_email.subject.#{@creator_request.status}")
    )
  end
end
