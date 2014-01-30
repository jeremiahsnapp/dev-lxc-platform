# byobu installs and enhances screen and tmux terminal multiplexers
package 'byobu'

directory '/root/.byobu' do
  recursive true
end

cookbook_file '/root/.byobu/keybindings.tmux' do
  source 'keybindings.tmux'
  action :create_if_missing
end

cookbook_file '/root/.byobu/.tmux.conf' do
  source 'tmux.conf'
  action :create_if_missing
end
