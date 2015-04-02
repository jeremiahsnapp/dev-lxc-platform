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

ruby_block "alias tls" do
  block do
    rc = Chef::Util::FileEdit.new("/root/.bashrc")
    rc.insert_line_if_no_match(/^alias tls=/, "alias tls='tmux ls'")
    rc.write_file
  end
end

ruby_block "alias tks" do
  block do
    rc = Chef::Util::FileEdit.new("/root/.bashrc")
    rc.insert_line_if_no_match(/^alias tks=/, "alias tks='tmux kill-session -t'")
    rc.write_file
  end
end
