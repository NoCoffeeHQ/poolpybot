RSpec.configure do |config|
  config.before(:each) do
    ActiveStorage::Current.url_options = { host: ENV['HOST'] }
  end
end