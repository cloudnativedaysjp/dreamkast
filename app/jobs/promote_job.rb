class PromoteJob < ApplicationJob
  def perform(record, name, file_data)
    attacher = Shrine::Attacher.retrieve(model: record, name: name, file: file_data)
    return unless attacher.file.exists?
    attacher.create_derivatives
    attacher.atomic_promote
  end
end
