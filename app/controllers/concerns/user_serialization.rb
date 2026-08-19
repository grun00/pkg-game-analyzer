module UserSerialization
  extend ActiveSupport::Concern

  private

  def user_json(u)
    { id: u.id, email: u.email, role: u.role }
  end
end
