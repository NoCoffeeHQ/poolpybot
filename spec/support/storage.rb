module ActiveStorageTestHelper
  def attachable_pdf(pdf_io)
    {
      io: pdf_io,
      filename: 'invoice_pdf',
      content_type: 'application/pdf'
    }
  end
end

RSpec.configure do |config|
  config.before(:each) do
    ActiveStorage::Current.url_options = { host: ENV['HOST'] }
    config.include ActiveStorageTestHelper
  end
end