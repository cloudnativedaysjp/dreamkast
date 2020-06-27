class TrackController < ApplicationController
  include Secured
  include Logging
  
  def show
    @new_user = new_user?.to_s
    case params[:id]
    when "1" then
      @movie_url = "https://www.youtube.com/embed/QJSo8BZlbeI"
    when "2" then
      @movie_url = "https://www.youtube.com/embed/i28YOIui1bc?autoplay=1"
    when "3" then
      @movie_url = "https://www.youtube.com/embed/bqD9EwKaE90?autoplay=1"
    when "4" then
      @movie_url = "https://www.youtube.com/embed/hL07TE17rZ8?autoplay=1"
    when "5" then
      @movie_url = "https://www.youtube.com/embed/rD9czFIT4Iw?autoplay=1"
    when "6" then
      @movie_url = "https://www.youtube.com/embed/sSGVgLmZ8u0?autoplay=1"
    end
  end
end
