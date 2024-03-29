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

  def grouped_months_for_select(grouped_months, selected)
    grouped_options_for_select(
      (grouped_months || [Time.zone.today.year, [Time.zone.today]]).inject([]) do |groups, (year, months)|
        groups.push([year, month_options(year, months)])
      end,
      selected
    )
  end

  def month_options(year, months)
    months.unshift(Time.zone.today) if year == Time.zone.today.year
    months.map { |date| [l(date, format: :month), date.strftime('%Y-%m')] }.uniq
  end

  def locales_choices
    %i[en fr].map do |locale|
      [t("locales.#{locale}"), locale]
    end
  end

  def report_frequencies_choices
    User.translated_report_frequencies.map { |translation, value, _| [translation, value] }
  end
end
