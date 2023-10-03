class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # Check if settings exist in session and set defaults if not
    @all_ratings = Movie.all_ratings
    @ratings_to_show = @all_ratings
  

    if (!params[:ratings] and session[:ratings]) or (!params[:sort_by] and session[:sort_by])
      redirect_to movies_path(:sort_by => session[:sort_by], :ratings => session[:ratings])
    end

    if params.has_key?(:ratings)
      if params[:ratings].keys.size > 0
        @ratings_to_show = []
        @all_ratings.each do |rating|
          if params[:ratings][rating] == "1"
            @ratings_to_show << rating
          end
        end
      end
    end

    if @ratings_to_show != []
      @movies = Movie.with_ratings(@ratings_to_show)
      session[:ratings]=params[:ratings]
    else
      @movies = Movie.all
    end

    if params[:sort_by]
      @movies = @movies.order(params[:sort_by])
      session[:sort_by] = params[:sort_by]
    end
    return @movies
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
