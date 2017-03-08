package 'tinyproxy'

cookbook_file '/etc/tinyproxy.conf' do
  source 'tinyproxy.conf'
  notifies :restart, 'service[tinyproxy]'
end

service 'tinyproxy' do
  action [:enable, :start]
end
