# /etc/puppet/modules/wsgi_tools/manifests/init.pp:
class wsgi_tools {
  $wsgiroot = '/etc/puppet/modules/wsgi'
  exec { 'apt-update':
    command => '/usr/bin/apt-get update'
  }
  Exec['apt-update'] -> Package <| |>
  $wsgi_things = ['python-virtualenv', 'rake', 'ruby']
  package { $wsgi_things:
    ensure  => 'installed',
  }
  user { 'faro':
    ensure     => 'present',
    managehome => true,
  }
}
