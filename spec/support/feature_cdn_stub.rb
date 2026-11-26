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
  # Chrome opens speculative connections that can sit idle, and the stub answers every
  # media request a page makes, so a connection that never speaks must not hold the
  # others up. These bound how long each stalled step keeps its own thread.
  HANDSHAKE_TIMEOUT = 5
  READ_TIMEOUT = 5

  class << self
    attr_reader :port

    def start
      return self if @port

      @tcp_server = TCPServer.new('127.0.0.1', 0)
      @port = @tcp_server.addr[1]
      @thread = Thread.new { serve }
      self
    end

    private

    # One thread per connection. The handshake happens inside `respond` rather than in
    # `accept`, so a client that connects and says nothing occupies only its own thread.
    def serve
      loop do
        connection = @tcp_server.accept
        Thread.new(connection) { |client| respond(client) }
      end
    rescue IOError, Errno::EBADF
      nil # the server was closed after the suite
    end

    def respond(connection)
      socket = OpenSSL::SSL::SSLSocket.new(connection, ssl_context)
      socket.sync_close = true
      socket.timeout = HANDSHAKE_TIMEOUT
      socket.accept
      socket.timeout = READ_TIMEOUT
      socket.gets # request line; every path is answered identically
      socket.write(RESPONSE)
    rescue StandardError
      nil # a client that gives up mid-connection is answered by closing it
    ensure
      socket&.close
      connection.close unless connection.closed?
    end

    # Built once: generating the key per connection would cost more than the request.
    def ssl_context
      @ssl_context ||= begin
        key = OpenSSL::PKey::RSA.new(2048)
        OpenSSL::SSL::SSLContext.new.tap do |context|
          context.cert, context.key = certificate(key)
        end
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
