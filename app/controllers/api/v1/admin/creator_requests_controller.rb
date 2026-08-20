module Api
  module V1
    module Admin
      class CreatorRequestsController < BaseController
        include CreatorRequestSerialization

        before_action :require_admin!

        def index
          requests = CreatorRequest.status_pending
                                   .includes(:user)
                                   .order(created_at: :asc)
          render json: requests.map { |r| creator_request_json(r) }
        end

        def update
          request = CreatorRequest.find(params[:id])
          status = decision_params[:status]

          unless CreatorRequest.statuses.key?(status) && status != "pending"
            return render json: { errors: [I18n.t("errors.invalid_role")] },
                          status: :unprocessable_content
          end

          apply_decision(request, status)
          CreatorRequestMailer.with(creator_request: request).decision_email.deliver_later
          render json: creator_request_json(request)
        end

        private

        def apply_decision(request, status)
          CreatorRequest.transaction do
            request.update!(status: status)
            request.user.update!(role: :content_creator) if status == "approved"
          end
        end

        def decision_params
          params.require(:creator_request).permit(:status)
        end
      end
    end
  end
end
