# /etc/puppet/manifests/site.pp

node default {
  include sudo
  include basic
  if 'jenkins' in $::hostname {
    include ci_tools
  }
  if 'wsgi' in $::hostname {
    include wsgi_tools
    include faro_api
  }
}
