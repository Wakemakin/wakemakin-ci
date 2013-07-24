# /etc/puppet/manifests/site.pp

node default {
  include sudo
  include basic
  if 'jenkins' in $::hostname {
    include ci_tools
  }
}
