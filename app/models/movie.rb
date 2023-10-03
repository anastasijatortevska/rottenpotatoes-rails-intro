class Movie < ActiveRecord::Base
  def self.all_ratings
    Movie.pluck(:rating).uniq
  end

  def self.with_ratings(ratings_list)
    if ratings_list.nil? || ratings_list.empty?
      return Movie.all
    else
      # Retrieve movies with the selected ratings
      return Movie.where(rating: ratings_list)
    end
  end
end
