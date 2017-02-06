node['dev-lxc-platform']['base_containers'].each do |bc|
  execute "Create base container #{bc}" do
    command "sudo -i chef exec dev-lxc create #{bc}"
    not_if "lxc-info -n #{bc}"
  end
end
