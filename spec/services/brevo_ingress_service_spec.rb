# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BrevoIngressService do
  let(:container) { ApplicationContainer.new }
  let(:instance) { container.brevo_ingress }
  let!(:company) { create(:company, :with_uuid) }

  subject { instance.call(items: items) }

  describe 'Given the email is a forward of an Apple Invoice' do
    let(:items) { brevo_items(:apple) }

    it 'creates the invoice in DB' do
      subject
    end
  end
end
