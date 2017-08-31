package 'curl'

package 'tree'

package 'htop'

package 'emacs24-nox'
cookbook_file '/root/.emacs' do
  source 'emacs'
  action :create_if_missing
end

package 'vim-nox'

remote_file "#{Chef::Config['file_cache_path']}/mitmproxy-1.0.2-linux.tar.gz" do
  source 'https://github.com/mitmproxy/mitmproxy/releases/download/v1.0.2/mitmproxy-1.0.2-linux.tar.gz'
  notifies :run, 'bash[extract mitmproxy]', :immediately
end

bash 'extract mitmproxy' do
  code "tar xzf #{Chef::Config['file_cache_path']}/mitmproxy-1.0.2-linux.tar.gz -C /usr/local/bin"
  action :nothing
end

ruby_block 'export LANG=en_US.UTF-8 for mitmproxy' do
  block do
    rc = Chef::Util::FileEdit.new('/root/.bashrc')
    rc.insert_line_if_no_match(/^export LANG=en_US.UTF-8$/, 'export LANG=en_US.UTF-8')
    rc.write_file
  end
end

ruby_block 'alias mitmproxy --insecure' do
  block do
    rc = Chef::Util::FileEdit.new('/root/.bashrc')
    rc.insert_line_if_no_match(/^alias mitmproxy='mitmproxy --insecure'$/, "alias mitmproxy='mitmproxy --insecure'")
    rc.write_file
  end
end

directory '/root/.berkshelf'
file '/root/.berkshelf/config.json' do
  content '{ "ssl": { "verify": false } }'
  action :create_if_missing
end

remote_file '/usr/local/bin/chef-load' do
  source 'https://github.com/chef/chef-load/releases/download/v3.0.0/chef-load_3.0.0_Linux_64bit'
  mode 0755
end
