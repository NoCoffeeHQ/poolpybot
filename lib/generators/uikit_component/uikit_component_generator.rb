# frozen_string_literal: true

# TO BE ADDED TO THE SaaS Rails template
class UikitComponentGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  argument :attributes, type: :array, default: [], banner: 'attribute'

  def create_component_file
    template 'component.rb', File.join(component_path, class_path, "#{file_name}_component.rb")
  end

  def copy_view_file
    template 'component.html.erb', File.join(component_path, class_path, "#{file_name}_component.html.erb")
  end

  private

  def class_name
    @class_name = file_name.camelcase
  end

  def file_name
    @file_name ||= super.underscore.sub(/_component\z/i, '')
  end

  def component_path
    ViewComponent::Base.config.view_component_path
  end

  def class_path
    "ui_kit/#{file_name}"
  end

  def accessors
    return if attributes.blank?

    attributes.map { |attr| ":#{attr.name}" }.join(', ')
  end

  def initialize_signature
    return if attributes.blank?

    attributes.map { |attr| "#{attr.name}:" }.join(', ')
  end

  def initialize_body
    attributes.map { |attr| "@#{attr.name} = #{attr.name}" }.join("\n    ")
  end
end
