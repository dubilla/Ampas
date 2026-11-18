# Fly's proxy appends its edge address to X-Forwarded-For, so Rails would take the
# edge as the client. Fly-Client-IP holds the real client and the proxy overwrites it.
class FlyClientIp
  def initialize(app)
    @app = app
  end

  def call(env)
    client_ip = env['HTTP_FLY_CLIENT_IP']
    env['HTTP_X_FORWARDED_FOR'] = client_ip if client_ip.present?
    @app.call(env)
  end
end
