json.array!(@printers) do |printer|
  json.id(printer.id)
  json.name(printer.name)
end
