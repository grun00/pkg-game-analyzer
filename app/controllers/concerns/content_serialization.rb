module ContentSerialization
  extend ActiveSupport::Concern
  include SubscriptionSerialization

  private

  # `ratings` are resolved in memory so callers can eager-load with
  # `.includes(:ratings)` and avoid N+1 in the index action.
  def content_json(content, current_user:)
    ratings = content.ratings.to_a
    mine = ratings.find { |r| r.user_id == current_user.id }

    {
      id: content.id,
      title: content.title,
      body: content.body,
      content_type: content.content_type,
      status: content.status,
      game_type: content.game_type,
      published_at: content.published_at&.iso8601,
      created_at: content.created_at,
      updated_at: content.updated_at,
      creator: public_creator_json(content.creator),
      average_rating: average_of(ratings),
      ratings_count: ratings.size,
      my_rating: mine&.stars
    }
  end

  def average_of(ratings)
    return 0.0 if ratings.empty?

    (ratings.sum(&:stars).to_f / ratings.size).round(2)
  end
end
