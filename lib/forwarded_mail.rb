# frozen_string_literal: true

module ForwardedMail
  def self.new(mail)
    ForwardedMail::Message.new(mail)
  end
end
