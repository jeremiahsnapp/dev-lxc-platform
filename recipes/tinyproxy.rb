package 'tinyproxy'

cookbook_file '/etc/systemd/system/tinyproxy.service' do
  source 'tinyproxy.service'
  notifies :restart, 'service[tinyproxy]'
end

cookbook_file '/etc/tinyproxy.conf' do
  source 'tinyproxy.conf'
  notifies :restart, 'service[tinyproxy]'
end

service 'tinyproxy' do
  action [:enable, :start]
end
