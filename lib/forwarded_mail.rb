module ForwardedMail
  def self.new(mail)
    ForwardedMail::Message.new(mail)
  end
end