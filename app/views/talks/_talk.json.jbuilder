json.extract!(talk, :id, :title, :abstract, :movie_url, :track, :start_time, :end_time, :difficulty_id, :category_id, :created_at, :updated_at)
json.url(talk_url(talk, format: :json))
