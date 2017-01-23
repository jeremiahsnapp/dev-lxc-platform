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
