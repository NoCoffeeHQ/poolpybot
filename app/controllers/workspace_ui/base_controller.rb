module WorkspaceUI
  class BaseController < ApplicationController
    layout 'workspace_ui'

    before_action :require_login

    private

    def current_company
      current_user&.company
    end
  end
end