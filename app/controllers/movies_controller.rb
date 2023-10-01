class MoviesController < ApplicationController
  before_action :set_all_ratings, only: :index

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # Check if settings exist in session and set defaults if not
    session[:ratings] ||= {}
    session[:sort] ||= 'title'
    session[:direction] ||= 'asc'
  
    # Retrieve ratings and sorting options from session or params
    selected_ratings = params[:ratings] || session[:ratings]
    sort_column = params[:sort] || session[:sort]
    direction = params[:direction] || session[:direction]
  
    # Store the current settings in session
    session[:ratings] = selected_ratings
    session[:sort] = sort_column
    session[:direction] = direction
  
    # Initialize @ratings_to_show to all ratings if it's nil
    # @ratings_to_show = selected_ratings.keys.presence || Movie.all_ratings
    @ratings_to_show = params[:ratings].present? ? params[:ratings].keys : Movie.all_ratings
    @ratings_to_show_hash = Hash[@ratings_to_show.collect { |key| [key, '1'] }]
    session[:ratings] = @ratings_to_show
  
    # Set @title_header and @release_date_header based on the current sort_column
    @title_header = sort_column == 'title' ? 'hilite' : ''
    @release_date_header = sort_column == 'release_date' ? 'hilite' : ''
  
    # Use the settings to filter and sort movies
    @movies = Movie.with_ratings(selected_ratings.keys).order(sort_column => direction)
    @all_ratings = Movie.all_ratings
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
