# ref: https://github.com/gmiranda23/ntp/issues/105#issuecomment-99144029
# ref: https://github.com/gmiranda23/ntp/issues/108
if node['platform'] == 'ubuntu' && node['platform_version'].to_f >= 15.04
  resources("service[ntp]").provider Chef::Provider::Service::Init::Debian
end
