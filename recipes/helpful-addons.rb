package 'curl'

package 'tree'

package 'htop'

if node['platform'] == 'ubuntu'
  case node['platform_version'].to_f
  when 14.04, 15.04
    package 'emacs24-nox'
  when 12.04
    package 'emacs23-nox'
  end
end
cookbook_file '/root/.emacs' do
  source 'emacs'
  action :create_if_missing
end

package 'vim-nox'

package 'parallel'
