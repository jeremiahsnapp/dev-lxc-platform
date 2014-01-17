package 'curl'

package 'emacs24-nox'
package 'vim-nox'

cookbook_file '/etc/profile.d/lxc-helpers.sh' do
  source 'lxc-helpers.sh'
end
