# Initialise rack-attack to protect against brute forcing.

# Only enable rack-attack on PRODUCTION and STAGING environments.
if Rails.env.production? || Rails.env.staging?

  # Whitelists any IPs that we know are OK.
  ra_whitelist = ""
  if ENV.key?("RACK_ATTACK_WHITELIST")
    ra_whitelist = ENV["RACK_ATTACK_WHITELIST"].to_s
  end
  ra_whitelist.split(/\s+/).reject(&:empty?).
    each { |ip| Rack::Attack.safelist_ip(ip) }

  # Blocks all requests from misbehaving clients.
  Rack::Attack.blocklist("fail2ban pentesters") do |req|
    Rack::Attack::Fail2Ban.filter(
      "pentesters/#{req.ip}",
      maxretry: 3,
      findtime: 10.minutes,
      bantime: 5.minutes,
    ) do
      CGI.unescape(req.query_string) =~ %r{/etc/passwd} ||
        req.path.include?("/etc/passwd") ||
        req.path.include?("wp-admin") ||
        req.path.include?("wp-login")
    end
  end

  # Throttles POST requests to /users pages by IP.
  Rack::Attack.throttle(
    "logins/ip",
    limit: 30,
    period: 60.seconds,
  ) do |req|
    if req.path.include?("/users") && req.post?
      req.ip
    end
  end

  # Throttles POST requests to /users pages by email param.
  Rack::Attack.throttle(
    "logins/ip+email",
    limit: 10,
    period: 60.seconds,
  ) do |req|
    if req.path.include?("/users") && req.post? && req.params.dig('user', 'email')
      "#{req.ip},#{req.params['user']['email']}"
    end
  end

  # Provides a custom response to blocked clients.
  Rack::Attack.blocklisted_response = lambda do |_env|
    [503, {}, ["Server error\n"]]
  end

  # Provides a custom response to throttled clients.
  Rack::Attack.throttled_response = lambda do |_env|
    [503, {}, ["Server error\n"]]
  end

end
