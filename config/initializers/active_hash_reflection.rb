module ActiveHashReflection
  extend ActiveSupport::Concern

  included do
    def compute_class(name)
      super
    rescue ArgumentError => e
      if e.message =~ /Please provide the :class_name option on the association/ && klass < ActiveHash::Base
        active_record.send(:compute_type, name)
      else
        raise
      end
    end
  end
end

Rails.application.reloader.to_prepare do
  ActiveRecord::Reflection::AssociationReflection.include ActiveHashReflection
end
