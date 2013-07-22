# /etc/puppet/modules/basic/manifests/init.pp
class basic {
  $basic_system = [ 'vim', 'tmux', 'git', 'python-pip',
                    'python-dev', 'build-essential' ]
  package { $basic_system:
    ensure => 'installed'
  }
}
