node['dev-lxc-platform']['base_containers'].each do |bc|
  execute "Create base container #{bc}" do
    command "chef exec dl create #{bc}"
    user 'root'
    environment({ 'HOME' => '/root' })
    not_if "lxc-info -n #{bc}"
  end
end
