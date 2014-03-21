package 'curl'

package 'tree'

package 'htop'

package 'emacs24-nox'
cookbook_file '/root/.emacs' do
  source 'emacs'
  action :create_if_missing
end

package 'vim-nox'
