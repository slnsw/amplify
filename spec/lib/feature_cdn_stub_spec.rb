# frozen_string_literal: true

require 'rails_helper'

# The stub answers every media request the project content makes, so a connection that
# never speaks must not hold the others up: Chrome opens speculative connections, and a
# stalled handshake used to block the stub's only accepting thread.
RSpec.describe FeatureCdnStub do
  describe '.start' do
    it 'answers a request while another connection sits idle' do
      stub = described_class.start
      idle = TCPSocket.new('127.0.0.1', stub.port)

      expect(tls_request(stub.port)).to include('200 OK')
    ensure
      idle&.close
    end

    it 'answers two requests in a row' do
      stub = described_class.start

      expect([tls_request(stub.port), tls_request(stub.port)]).to all(include('200 OK'))
    end
  end

  private

  def tls_request(port)
    context = OpenSSL::SSL::SSLContext.new
    context.verify_mode = OpenSSL::SSL::VERIFY_NONE
    socket = OpenSSL::SSL::SSLSocket.new(TCPSocket.new('127.0.0.1', port), context)
    socket.sync_close = true
    # Bounded so a stub that is not answering fails these examples instead of hanging.
    socket.timeout = 5
    socket.connect
    socket.write("GET /#{FeatureCdnStub::HOST}/media.mp4 HTTP/1.1\r\nHost: #{FeatureCdnStub::HOST}\r\n\r\n")
    socket.read
  ensure
    socket&.close
  end
end
