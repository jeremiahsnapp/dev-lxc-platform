chef_gem 'knife-config'

cookbook_file 'knife-aliases.sh' do
  path '/etc/profile.d/knife-aliases.sh'
end

package 'curl'

package 'emacs24-nox'
package 'vim-nox'

# byobu installs and enhances screen and tmux terminal multiplexers
package 'byobu'
