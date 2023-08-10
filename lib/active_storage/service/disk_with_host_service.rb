require "active_storage/service/disk_service"

class ActiveStorage::Service::DiskWithHostService < ActiveStorage::Service::DiskService
  def url_options
    Rails.application.default_url_options # or something else for greater flexibility
  end
end