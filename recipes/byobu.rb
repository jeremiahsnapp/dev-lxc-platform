# byobu installs and enhances screen and tmux terminal multiplexers
package 'byobu'

directory '/root/.byobu' do
  recursive true
end

cookbook_file '/root/.byobu/.tmux.conf' do
  source 'tmux.conf'
  action :create_if_missing
end
