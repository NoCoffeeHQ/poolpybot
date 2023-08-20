# frozen_string_literal: true

class UIKit::DirectUploadButton::DirectUploadButtonComponent < ViewComponent::Base
  attr_reader :label, :url, :accept, :multiple

  def initialize(label:, url:, accept: nil, multiple: false)
    super
    @label = label
    @url = url
    @accept = accept
    @multiple = multiple
  end

  def uploading_label
    t('.uploading_label')
  end
end
