# frozen_string_literal: true

require_relative 'read_only_guard'

# Local unit test for the read-only guard: it parses the entries Chrome's
# performance log reports, so it needs no browser and no remote host.
RSpec.describe Staging::ReadOnlyGuard do
  it 'raises when a non-GET request is recorded' do
    logs = logs_for('POST', 'https://example.test/transcripts')

    expect { described_class.assert_read_only!(logs) }
      .to raise_error(Staging::ReadOnlyGuard::WriteAttempted, %r{POST https://example.test/transcripts})
  end

  it 'passes when only GET requests were recorded' do
    expect(described_class.assert_read_only!(logs_for('GET', 'https://example.test/'))).to be_nil
  end

  it 'ignores log entries that are not requests (e.g. response events)' do
    logs = [{ message: JSON.dump('message' => { 'method' => 'Network.responseReceived',
                                                'params' => { 'response' => { 'url' => 'https://example.test/' } } }) }]

    expect(described_class.assert_read_only!(logs)).to be_nil
  end

  # What `check!` hands over: the raw messages `browser.logs.get(:performance)`
  # carries, which is the shape a browser run actually produces.
  it 'reads the raw message strings Chrome reports' do
    logs = [JSON.dump('message' => { 'method' => 'Network.requestWillBeSent',
                                     'params' => { 'request' => { 'method' => 'POST',
                                                                  'url' => 'https://example.test/write' } } })]

    expect { described_class.assert_read_only!(logs, target: 'https://example.test') }
      .to raise_error(Staging::ReadOnlyGuard::WriteAttempted, %r{POST https://example.test/write})
  end

  describe 'the writes a read-only run is allowed to make' do
    let(:target) { 'https://staging.example.test' }

    it 'tolerates the sign-in POST that establishes the authenticated session' do
      expect(described_class.assert_read_only!(logs_for('POST', "#{target}/users/sign_in"), target: target)).to be_nil
    end

    it 'tolerates the browser posting a report-only CSP violation' do
      logs = logs_for('POST', "#{target}/csp-violation-report-endpoint")

      expect(described_class.assert_read_only!(logs, target: target)).to be_nil
    end

    it 'tolerates an analytics beacon the deployed layout loads' do
      logs = logs_for('POST', 'https://region1.google-analytics.com/g/collect')

      expect(described_class.assert_read_only!(logs, target: target)).to be_nil
    end

    it 'still raises for any other write to the deployment' do
      logs = logs_for('POST', "#{target}/admin/pages/1/upload")

      expect { described_class.assert_read_only!(logs, target: target) }
        .to raise_error(Staging::ReadOnlyGuard::WriteAttempted, %r{POST https://staging.example.test/admin/pages/1/upload})
    end

    it 'raises for a write to the S3 bucket the environment shares with production' do
      logs = logs_for('PUT', 'https://slnsw-amplify.s3.amazonaws.com/uploads/page/image.png')

      expect { described_class.assert_read_only!(logs, target: target) }
        .to raise_error(Staging::ReadOnlyGuard::WriteAttempted)
    end

    it 'raises for a write to an origin it does not recognise' do
      logs = logs_for('POST', 'https://collect.example.test/ingest')

      expect { described_class.assert_read_only!(logs, target: target) }
        .to raise_error(Staging::ReadOnlyGuard::WriteAttempted)
    end
  end

  # GET is not read-only in this app, so a GET to one of these paths fails the
  # run exactly as a write does.
  describe 'the GETs that change the deployment or the session' do
    let(:target) { 'https://staging.example.test' }

    it 'raises for the CMS sync that enqueues a paid Azure job' do
      logs = logs_for('GET', "#{target}/admin/cms/transcripts/42/sync")

      expect { described_class.assert_read_only!(logs, target: target) }
        .to raise_error(Staging::ReadOnlyGuard::WriteAttempted, %r{GET https://staging.example.test/admin/cms/transcripts/42/sync})
    end

    it 'raises for the GET sign-out that ends the session' do
      logs = logs_for('GET', "#{target}/users/sign_out")

      expect { described_class.assert_read_only!(logs, target: target) }
        .to raise_error(Staging::ReadOnlyGuard::WriteAttempted, %r{GET https://staging.example.test/users/sign_out})
    end

    it 'still passes ordinary GETs, including one whose path merely mentions sync' do
      logs = logs_for('GET', "#{target}/admin/cms/transcripts/42/edit") +
             logs_for('GET', "#{target}/search?search=sync")

      expect(described_class.assert_read_only!(logs, target: target)).to be_nil
    end

    it 'ignores a /sync endpoint on another host' do
      logs = logs_for('GET', 'https://cm.example-ads.test/sync')

      expect(described_class.assert_read_only!(logs, target: target)).to be_nil
    end
  end

  def logs_for(method, url)
    [{ message: JSON.dump('message' => { 'method' => 'Network.requestWillBeSent',
                                         'params' => { 'request' => { 'method' => method, 'url' => url } } }) }]
  end
end
