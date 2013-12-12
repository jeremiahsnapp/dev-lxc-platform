package 'curl'

package 'emacs24-nox'
package 'vim-nox'

# byobu installs and enhances screen and tmux terminal multiplexers
package 'byobu'

cookbook_file 'knife-zero.sh' do
  path '/etc/profile.d/knife-zero.sh'
end
