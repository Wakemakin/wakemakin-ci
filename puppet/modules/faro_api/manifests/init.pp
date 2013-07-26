# /etc/puppet/modules/faro_api/manifests/init.pp:
class faro_api {
  $ciroot = '/etc/puppet/modules/ci_tools'
  $faro_api_root = '/etc/puppet/modules/faro_api'
  $faro_api_things = ['faro-api', 'libmysqlclient-dev']
  package { $faro_api_things:
    ensure  => 'installed',
  }
  file { '/etc/faro':
    ensure  => 'directory',
    owner   => 'faro',
  }
  file { '/etc/faro/faro-api':
    ensure  => 'directory',
    owner   => 'faro',
  }
  file { '/etc/faro/faro-api/faro-api.conf':
    ensure  => 'present',
    source  => "${faro_api_root}/faro-api.conf",
    owner   => 'faro',
  }
  file { '/etc/apt/trusted.gpg.d/keyring.gpg':
    ensure  => 'present',
    source  => "${ciroot}/freight/keyring.gpg",
    owner   => 'faro',
  }
  file { '/etc/apt/trusted.gpg.d/pubkey.gpg':
    ensure  => 'present',
    source  => "${ciroot}/freight/pubkey.gpg",
    owner   => 'faro',
  }
  apt::source { 'local_repo':
    location          => 'http://apt.jibely.com',
    release           => 'saucy',
    repos             => 'main',
    required_packages => 'debian-keyring debian-archive-keyring',
    include_src       => false,
  }
  supervisor::service {
    'faro_api':
      ensure  => present,
      enable  => true,
      command => '/opt/faro/faro-api/service-start.sh',
      user    => 'faro',
  }
  class { 'mysql::python': }
  class { 'mysql::server':
    config_hash => { 'root_password' => 'password' }
  }
  mysql::db { 'faro_api':
    user     => 'faro',
    password => 'faro_password',
    host     => 'localhost',
    grant    => ['all'],
  }
}
