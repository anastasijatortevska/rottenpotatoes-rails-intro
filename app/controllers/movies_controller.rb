class MoviesController < ApplicationController
  before_action :set_all_ratings, only: :index

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    selected_ratings = params[:ratings]&.keys || []
    @ratings_to_show = selected_ratings
  
    sort_column = nil
    default_direction = 'asc'
  
    if params[:sort] == 'title' || params[:sort] == 'release_date'
      sort_column = params[:sort].to_sym
      direction = (params[:sort] == session[:sort] && session[:direction] == 'asc') ? 'desc' : 'asc'
    else
      sort_column = session[:sort]
      direction = session[:direction] || default_direction
    end
  
    session[:sort] = sort_column
    session[:direction] = direction
  
    @movies = Movie.with_ratings(selected_ratings).order(sort_column => direction)
  
    @ratings_url_params = Hash[selected_ratings.map { |rating| [:"ratings[#{rating}]", '1'] }]
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

  def set_all_ratings
    @all_ratings = Movie.all_ratings
  end
end
