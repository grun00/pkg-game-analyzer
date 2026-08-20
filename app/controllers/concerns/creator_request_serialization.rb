module CreatorRequestSerialization
  extend ActiveSupport::Concern
  include UserSerialization

  private

  def creator_request_json(request)
    {
      id: request.id,
      status: request.status,
      message: request.message,
      created_at: request.created_at,
      updated_at: request.updated_at,
      user: user_json(request.user)
    }
  end
end
