class ContentStatsService
  def initialize(ratings)
    @ratings = ratings
  end

  def call
    {
      average_rating: average_rating,
      ratings_count: ratings_count,
      by_star: by_star
    }
  end

  private

  def ratings_count
    @ratings.count
  end

  def average_rating
    return 0.0 if ratings_count.zero?

    @ratings.average(:stars).to_f.round(2)
  end

  def by_star
    (1..5).map do |star|
      { star: star, count: @ratings.where(stars: star).count }
    end
  end
end
