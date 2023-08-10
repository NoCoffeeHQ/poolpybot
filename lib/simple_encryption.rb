# frozen_string_literal: true

require 'openssl'

module SimpleEncryption
  def self.encrypt(string)
    cipher = OpenSSL::Cipher.new('aes-256-cbc').encrypt
    cipher.key = Digest::MD5.hexdigest(secret_key)
    s = cipher.update(string) + cipher.final

    s.unpack1('H*').upcase
  end

  def self.decrypt(string)
    cipher = OpenSSL::Cipher.new('aes-256-cbc').decrypt
    cipher.key = Digest::MD5.hexdigest(secret_key)
    s = [string].pack('H*').unpack('C*').pack('c*')

    cipher.update(s) + cipher.final
  end

  def self.secret_key
    credentials[:secret_key_base]
  end

  def self.credentials
    Rails.application.credentials
  end
end
