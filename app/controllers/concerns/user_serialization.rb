module UserSerialization
  extend ActiveSupport::Concern

  private

  def user_json(u)
    { id: u.id, email: u.email, role: u.role, name: u.name, bio: u.bio }
  end
end
