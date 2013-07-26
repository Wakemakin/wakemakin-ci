# /etc/puppet/manifests/site.pp

node /jenkins/ {
    include sudo
    include basic
    include ci_tools
}

node /wsgi/ {
    class { 'supervisor':
      conf_dir => '/etc/supervisor.conf.d',
      conf_ext => '.conf',
    }
    include supervisor
    include mysql
    include wsgi_tools
    include faro_api
}
