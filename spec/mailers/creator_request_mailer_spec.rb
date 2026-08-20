require "rails_helper"

RSpec.describe CreatorRequestMailer, type: :mailer do
  let(:user) { create(:user, email: "applicant@pokemon.test") }

  describe "#submission_email" do
    let(:creator_request) { create(:creator_request, user: user) }
    let(:mail) { described_class.with(creator_request: creator_request).submission_email }

    it "is addressed to the admin recipient" do
      expect(mail.to).to eq([CreatorRequestMailer::ADMIN_RECIPIENT])
    end

    it "sets a subject including the applicant email" do
      expect(mail.subject).to include(user.email)
    end

    it "mentions the applicant email in the body" do
      expect(mail.body.encoded).to include(user.email)
    end
  end

  describe "#decision_email (approved)" do
    let(:creator_request) { create(:creator_request, :approved, user: user) }
    let(:mail) { described_class.with(creator_request: creator_request).decision_email }

    it "is addressed to the applicant" do
      expect(mail.to).to eq([user.email])
    end

    it "uses the approved subject" do
      expect(mail.subject).to eq(I18n.t("creator_request_mailer.decision_email.subject.approved"))
    end

    it "includes the approval message" do
      expect(mail.text_part.decoded).to include(I18n.t("creator_request_mailer.decision_email.approved"))
    end
  end

  describe "#decision_email (rejected)" do
    let(:creator_request) { create(:creator_request, :rejected, user: user) }
    let(:mail) { described_class.with(creator_request: creator_request).decision_email }

    it "uses the rejected subject" do
      expect(mail.subject).to eq(I18n.t("creator_request_mailer.decision_email.subject.rejected"))
    end

    it "includes the rejection message" do
      expect(mail.text_part.decoded).to include(I18n.t("creator_request_mailer.decision_email.rejected"))
    end
  end
end
