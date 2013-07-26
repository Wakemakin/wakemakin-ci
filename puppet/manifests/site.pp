# /etc/puppet/manifests/site.pp

node default {
  include sudo
  include basic
  if 'jenkins' in $::hostname {
    include ci_tools
  }
  if 'wsgi' in $::hostname {
    class { 'supervisor':
      conf_dir => '/etc/supervisor.conf.d',
      conf_ext => '.conf',
    }
    include supervisor
    include mysql
    include wsgi_tools
    include faro_api
  }
}
