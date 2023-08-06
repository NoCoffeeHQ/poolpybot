# frozen_string_literal: true

# Inspired by https://github.com/rest-client/rest-client
module SimpleRestClient
  def get(url, headers = {}, limit = 10)
    raise ArgumentError, 'HTTP redirect too deep' if limit.zero?

    response = get_without_redirection(url, headers)

    return get(response['location'], headers, limit - 1) if redirection?(response)

    response
  end

  def post(url, payload, headers = {})
    post_or_put(:post, url, payload, headers)
  end

  def put(url, payload, headers = {})
    post_or_put(:put, url, payload, headers)
  end

  private

  def get_without_redirection(url, headers = {})
    uri = URI.parse(url)
    request = Net::HTTP::Get.new(uri, headers)
    options = { use_ssl: uri.scheme == 'https' }
    Net::HTTP.start(uri.hostname, uri.port, options) do |http|
      http.request(request)
    end
  end

  def post_or_put(verb, url, payload, headers = {})
    uri = URI.parse(url)
    request = generic_post_or_put(verb, uri, payload, headers)
    options = { use_ssl: uri.scheme == 'https' }

    Net::HTTP.start(uri.hostname, uri.port, options) do |http|
      http.request(request)
    end
  end

  def generic_post_or_put(verb, uri, payload, headers = {})
    klass = Net::HTTP.const_get(verb.to_s.capitalize)
    request = klass.new(uri, headers)
    if headers['Content-Type']&.include?('application/json')
      request.body = payload.to_json
    else
      request.set_form_data(payload)
    end
    request
  end

  def redirection?(response)
    response.is_a?(Net::HTTPRedirection)
  end

  def build_response(response)
    status = response.code.starts_with?('20') # 200, 201
    json_response = begin
      JSON.parse(response.body)
    rescue StandardError
      response.body
    end
    [status, block_given? ? yield(status, json_response) : json_response]
  end

  def do_and_retry(max_retries: 5)
    attempts ||= 0
    yield
  rescue Net::ReadTimeout, Net::OpenTimeout, Errno::ECONNRESET, SocketError, OpenSSL::SSL::SSLError => e
    if (attempts += 1) <= max_retries
      # grant times to the external API between retries
      sleep(delay_in_ms_between_2_retries(attempts - 1))
      retry
    else
      Rails.logger.warn "[SimpleRestClient] network error, error=#{e.inspect}"
      nil
    end
  end

  def delay_in_ms_between_2_retries(attempts)
    # the delay is based on the fibonacci sequence.
    0.2 * ([1, 1, 2, 3, 5, 8, 13, 21, 34][attempts] || 1)
  end
end
