# frozen_string_literal: true

require 'openssl'
require 'socket'

# The project content the pages render (`public/<project>/project.js`, built from
# `project/<project>/pages/**`) points its videos, posters and images at
# `https://s3.amazonaws.com/togetherwelisten.nypl.org`, a CDN this environment
# cannot reach. Every `:js` example that loads the home page or the transcript
# editor requests them, the requests time out tens of seconds later, and Chrome
# logs each failure as a SEVERE console entry — which
# spec/support/features/javascript_errors.rb reports in whichever example reads
# the browser log next, failing an unrelated example at random.
#
# Answering those requests here (the driver maps the CDN's host to this stub, see
# spec/support/capybara.rb) keeps the browser hermetic: the media fails to
# decode, which is silent, instead of failing to load, which is not.
module FeatureCdnStub
  HOST = 's3.amazonaws.com'
  RESPONSE = "HTTP/1.1 200 OK\r\nContent-Length: 0\r\nConnection: close\r\n\r\n"
  CERTIFICATE_DAYS = 1

  class << self
    attr_reader :port

    def start
      return self if @port

      @server = OpenSSL::SSL::SSLServer.new(TCPServer.new('127.0.0.1', 0), ssl_context)
      @port = @server.to_io.addr[1]
      @thread = Thread.new { serve }
      self
    end

    private

    def serve
      loop do
        socket = @server.accept
        socket.gets # request line; every path is answered identically
        socket.write(RESPONSE)
        socket.close
      rescue StandardError
        next
      end
    rescue IOError, Errno::EBADF
      nil # the server was closed after the suite
    end

    def ssl_context
      key = OpenSSL::PKey::RSA.new(2048)
      OpenSSL::SSL::SSLContext.new.tap do |context|
        context.cert, context.key = certificate(key)
      end
    end

    def certificate(key)
      name = OpenSSL::X509::Name.parse("/CN=#{HOST}")
      certificate = OpenSSL::X509::Certificate.new
      certificate.version = 2
      certificate.serial = 1
      certificate.public_key = key.public_key
      certificate.subject = certificate.issuer = name
      sign(certificate, key)
      [certificate, key]
    end

    def sign(certificate, key)
      certificate.not_before = Time.current - 60
      certificate.not_after = Time.current + (CERTIFICATE_DAYS * 86_400)
      certificate.sign(key, OpenSSL::Digest.new('SHA256'))
    end
  end
end

RSpec.configure do |config|
  config.before(:suite) { FeatureCdnStub.start }
end
