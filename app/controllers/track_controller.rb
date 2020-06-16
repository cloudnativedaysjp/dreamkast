class TrackController < ApplicationController
  include Secured
  include Logging
  
  def show
    case params[:id]
    when "1" then
      @movie_url = "https://www.youtube.com/embed/QJSo8BZlbeI?autoplay=1"
    when "2" then
      @movie_url = "https://www.youtube.com/embed/i28YOIui1bc?autoplay=1"
    when "3" then
      @movie_url = ""
    when "4" then
      @movie_url = ""
    when "5" then
      @movie_url = ""
    when "6" then
      @movie_url = ""
    end
  end
end
