# frozen_string_literal: true

module ApplicationHelper
  # TO BE ADDED TO THE SaaS Rails template
  # Shortcut to render a UIKit component
  def ui_kit(name, **args, &block)
    instance = "UIKit::#{name.to_s.camelize}::#{name.to_s.camelize}Component".constantize.new(**args)
    render(instance, &block)
  end

  # TO BE ADDED TO THE SaaS Rails template
  # Shortcut to render a UIKit component
  def app_kit(name, **args, &block)
    instance = "AppKit::#{name.to_s.camelize}::#{name.to_s.camelize}Component".constantize.new(**args)
    render(instance, &block)
  end

  # Notification
  def notification; end
end
