json.array!(@streamings) do |streaming|
  json.id(streaming.id)
  json.status(streaming.status)
end
