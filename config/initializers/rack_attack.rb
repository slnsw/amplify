# Initialise rack-attack to protect against brute forcing.

# Whitelists any IPs that we know are OK.
ra_whitelist = ""
if ENV.key?("RACK_ATTACK_WHITELIST")
  ra_whitelist = ENV["RACK_ATTACK_WHITELIST"].to_s
end
ra_whitelist.split(/\s+/).reject(&:empty?).
  each { |ip| Rack::Attack.safelist_ip(ip) }

# Blocks all requests from misbehaving clients.
Rack::Attack.blocklist("fail2ban pentesters") do |req|
  Rack::Attack.Fail2Ban.filter(
    "pentesters-#{req.ip}",
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
  "limit users page attempts by ip",
  limit: 10,
  period: 60,
) do |req|
  if req.path.include?("/users") && req.post?
    req.ip
  end
end

# Provides a custom response to throttled clients.
Rack::Attack.throttled_response = lambda do |env|
  match_data = env["rack.attack.match_data"]
  now = match_data[:epoch_time]

  headers = {
    "RateLimit-Limit" => match_data[:limit].to_s,
    "RateLimit-Remaining" => 0,
    "RateLimit-Reset" => (now + (
      match_data[:period] - now % match_data[:period]
    )) / to_s,
  }

  [429, headers, ["Too many requests\n"]]
end