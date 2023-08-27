# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ForwardedMailSanitizer do
  subject { ForwardedMailSanitizer.call(html: html) }

  describe 'Given the mail was forwarded from Gmail' do
    let(:html) { File.read(file_fixture('mails/forwarded_from_gmail.html')) }

    it 'removes the extra headed added when the mail was forwarded' do
      is_expected.not_to include('---------- Message transféré ---------')
      is_expected.to include('Please find attached an invoice for your recent GitHub purchase.')
    end
  end
end
