# frozen_string_literal: true

# TO BE ADDED TO THE SaaS Rails template
# rubocop:disable Rails/OutputSafety
ActionView::Base.field_error_proc = proc do |html_tag, _instance|
  html_tag.html_safe
end
# rubocop:enable Rails/OutputSafety
