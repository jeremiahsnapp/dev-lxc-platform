package 'curl'

package 'emacs24-nox'
package 'vim-nox'

# byobu installs and enhances screen and tmux terminal multiplexers
package 'byobu'

cookbook_file '/etc/profile.d/lxc-helpers.sh' do
  source 'lxc-helpers.sh'
end
