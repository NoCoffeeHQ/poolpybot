# frozen_string_literal: true

module WorkspaceUI
  class CompanyController < BaseController
    def update
      if current_company.update(company_params)
        respond_to do |format|
          format.html { redirect_to edit_workspace_settings_path, notice: t('.flash.success') }
          format.turbo_stream { flash.now[:notice] = t('.flash.success') }
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def company_params
      params.require(:company).permit(:name)
    end
  end
end
