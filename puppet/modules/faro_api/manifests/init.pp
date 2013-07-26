# /etc/puppet/modules/faro_api/manifests/init.pp:
class faro_api {
  $ciroot = '/etc/puppet/modules/ci_tools'
  $faro_api_root = '/etc/puppet/modules/faro_api'
  $faro_api_things = ['faro-api']
  package { $faro_api_things:
    ensure  => 'installed',
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
}
