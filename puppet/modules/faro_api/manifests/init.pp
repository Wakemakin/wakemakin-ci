# /etc/puppet/modules/faro_api/manifests/init.pp:
class faro_api {
  $ciroot = '/etc/puppet/modules/ci_tools'
  $faro_api_root = '/etc/puppet/modules/faro_api'
  $api = '/opt/faro/faro-api'
  $bin = "${api}/.venv/bin"
  $app = 'faro_api:app().wsgi_app'
  $faro_api_things = ['libmysqlclient-dev']
  package { $faro_api_things:
    ensure  => 'installed',
  }
  package { 'faro-api':
    ensure => 'latest',
    notify => Exec['faro_api_kill'],
  }
  file { '/etc/faro':
    ensure  => 'directory',
    owner   => 'faro',
  }
  file { '/etc/faro/faro-api':
    ensure  => 'directory',
    owner   => 'faro',
  }
  file { '/etc/nginx/sites-available/faro_site':
    ensure  => 'present',
    notify  => Service['nginx'],
    source  => "${faro_api_root}/faro_site",
    mode    => '0644',
    require => Package['nginx'],
  }->
  file { '/etc/nginx/sites-enabled/faro_site':
    ensure  => 'link',
    notify  => Service['nginx'],
    target  => '/etc/nginx/sites-available/faro_site',
    require => Package['nginx'],
  }
  file { '/etc/faro/faro-api/faro-api.conf':
    ensure  => 'present',
    source  => "${faro_api_root}/faro-api.conf",
    owner   => 'faro',
  }
  $status = 'supervisorctl status faro_api'
  $sed = 'sed "s/.*[pid ]\([0-9]\+\)\,.*/\1/"'
  exec { 'faro_api_kill':
    command     => "${status} | ${sed} | xargs kill || true",
    subscribe   => File['/etc/faro/faro-api/faro-api.conf'],
    path        => '/usr/local/bin:/usr/bin:/bin',
    refreshonly => true,
    notify => Exec['faro_api_restart'],
  }
  exec { 'faro_api_restart':
    command     => "supervisorctl restart faro_api",
    path        => '/usr/local/bin:/usr/bin:/bin',
    refreshonly => true,
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
      ensure     => present,
      enable     => true,
      command    => "${bin}/gunicorn -c ${api}/gunicorn/conf.py ${app}",
      directory  => "${api}/",
      user       => 'faro',
      stopsignal => 'KILL',
      require    => [ Package['faro-api'] ];
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
