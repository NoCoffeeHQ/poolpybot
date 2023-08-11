# frozen_string_literal: true

# TO BE ADDED TO THE SaaS Rails template
require 'rails/arel_extensions'

# TO BE ADDED TO THE SaaS Rails template
# rubocop:disable Rails/OutputSafety
ActionView::Base.field_error_proc = proc do |html_tag, _instance|
  html_tag.html_safe
end
# rubocop:enable Rails/OutputSafety

# Hack to prevent anybody to view an uploaded document
Rails.application.config.after_initialize do
  ActiveStorage::BaseController.class_eval do
    before_action :require_login

    private

    def not_authenticated
      redirect_to main_app.sign_in_path, alert: t('notice.not_authenticated')
    end
  end
end

