module Api
  module V1
    class CreatorRequestsController < BaseController
      include CreatorRequestSerialization

      def index
        requests = current_user.creator_requests.order(created_at: :desc)
        render json: requests.map { |r| creator_request_json(r) }
      end

      def create
        request = current_user.creator_requests.new(creator_request_params)
        request.save!
        CreatorRequestMailer.with(creator_request: request).submission_email.deliver_later
        render json: creator_request_json(request), status: :created
      end

      private

      def creator_request_params
        params.require(:creator_request).permit(:message, :proposed_name, :proposed_bio)
      end
    end
  end
end
