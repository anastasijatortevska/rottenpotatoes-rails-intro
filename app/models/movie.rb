class Movie < ActiveRecord::Base
  def self.all_ratings
    distinct_ratings = Movie.distinct.pluck(:rating)
    distinct_ratings.sort
  end

  def self.with_ratings(ratings_list)
    if ratings_list.nil? || ratings_list.empty?
      # If no ratings are selected, retrieve ALL movies
      Movie.all
    else
      # Retrieve movies with the selected ratings
      Movie.where(rating: ratings_list)
    end
  end
end
