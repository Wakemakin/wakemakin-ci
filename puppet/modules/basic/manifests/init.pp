# /etc/puppet/modules/basic/manifests/init.pp
class basic {
  $ciroot = '/etc/puppet/modules/ci_tools'
  $basic_system = [ 'vim', 'tmux', 'git', 'python-pip', 'nginx',
                    'python-dev', 'build-essential' ]
  package { $basic_system:
    ensure => 'installed'
  }
  file { '/etc/apt/apt.conf.d/99auth':
    owner     => 'root',
    group     => 'root',
    content   => 'APT::Get::AllowUnauthenticated yes;',
    mode      => '0644';
  }
  file { '/etc/apt/trusted.gpg.d/Release.gpg':
    ensure  => 'present',
    source  => "${ciroot}/freight/Release.gpg",
    owner   => 'root',
  }
  # nginx settings
  service { 'nginx':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    require    => Package['nginx'],
  }
  file { '/etc/nginx/sites-available/default':
    ensure  => 'absent',
    notify  => Service['nginx'],
    require => Package['nginx'],
  }
}
