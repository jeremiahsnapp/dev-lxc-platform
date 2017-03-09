name              'dev-lxc-platform'
license           'Apache 2.0'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           '11.0.0'

supports 'ubuntu'

depends 'build-essential'
depends 'docker'
depends 'ntp'
depends 'sysdig'

source_url 'https://github.com/jeremiahsnapp/dev-lxc-platform'
issues_url 'https://github.com/jeremiahsnapp/dev-lxc-platform/issues'
chef_version '>= 12.5' if respond_to?(:chef_version)
