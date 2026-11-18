require 'rails_helper'
require Rails.root.join('lib/fly_client_ip')

RSpec.describe FlyClientIp do
  def remote_ip_for(headers)
    app = FlyClientIp.new(ActionDispatch::RemoteIp.new(->(env) { [200, {}, [env['action_dispatch.remote_ip'].to_s]] }))
    env = Rack::MockRequest.env_for('/', { 'REMOTE_ADDR' => '172.16.0.2' }.merge(headers))
    app.call(env).last.first
  end

  it 'uses Fly-Client-IP over the edge address Fly appends to X-Forwarded-For' do
    ip = remote_ip_for('HTTP_FLY_CLIENT_IP' => '203.0.113.7',
                       'HTTP_X_FORWARDED_FOR' => '203.0.113.7, 66.241.124.2')
    expect(ip).to eq('203.0.113.7')
  end

  it 'leaves X-Forwarded-For alone without Fly-Client-IP' do
    expect(remote_ip_for('HTTP_X_FORWARDED_FOR' => '198.51.100.4')).to eq('198.51.100.4')
  end
end
