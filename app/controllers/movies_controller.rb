class MoviesController < ApplicationController

  # GET /movies
  # GET /movies.json
  def index
    @movies = current_user.movies
  end
  # POST /movies
  # POST /movies.json
  def create
    id = params["id"].to_i
    movies = Movie.where(movie_id: id)
    if movies.empty?
      movie = Movie.new
      movie.movie_id = id
      movie.title = params["title"]
      movie.poster_url = params['poster_path']
      movie.short_desc = params['short_desc']
      puts movie
      if movie.save
        puts "yes"
      end
    else
      movie = movies.first
    end
    if (!current_user.movies.include?(movie))
      current_user.movies << movie
    end

  end

  # PATCH/PUT /movies/1
  # PATCH/PUT /movies/1.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: 'Movie was successfully updated.' }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1
  # DELETE /movies/1.json
  def destroy
    @movie.destroy
    respond_to do |format|
      format.html { redirect_to movies_url, notice: 'Movie was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    

    # Never trust parameters from the scary internet, only allow the white list through.
    def movie_params
      params.require(:movie).permit(:movie_id, :poster_url, :title, :short_desc)
    end
end
