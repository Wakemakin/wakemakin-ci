# /etc/puppet/modules/ci_tools/manifests/init.pp:
class ci_tools {
  $ciroot = '/etc/puppet/modules/ci_tools'
  exec { 'apt-update':
    command => '/usr/bin/apt-get update'
  }
  Exec['apt-update'] -> Package <| |>
  $ci_things = ['nginx', 'python-virtualenv', 'gnupg-agent',
                'rake', 'ruby', 'ruby1.9.1-dev', 'apache2-utils']
  package { $ci_things:
    ensure  => 'installed',
  }

  # nginx settings
  service { 'nginx':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    require    => Package['nginx'],
  }
  file { '/etc/nginx/sites-available/freight':
    ensure  => 'present',
    notify  => Service['nginx'],
    source  => "${ciroot}/nginx/sites-available/freight",
    mode    => '0644',
    require => Package['nginx'],
  }
  file { '/etc/nginx/sites-enabled/freight':
    ensure  => 'link',
    notify  => Service['nginx'],
    target  => "${ciroot}/nginx/sites-available/freight",
    require => Package['nginx'],
  }
  file { '/etc/nginx/sites-available/jenkins':
    ensure  => 'present',
    notify  => Service['nginx'],
    source  => "${ciroot}/nginx/sites-available/jenkins",
    mode    => '0644',
    require => Package['nginx'],
  }
  file { '/etc/nginx/htpasswd':
    ensure  => 'present',
    notify  => Service['nginx'],
    target  => "${ciroot}/nginx/htpasswd",
    require => Package['nginx'],
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
  }
  file { '/etc/nginx/sites-enabled/jenkins':
    ensure  => 'link',
    notify  => Service['nginx'],
    target  => "${ciroot}/nginx/sites-available/jenkins",
    require => Package['nginx'],
  }
  file { '/etc/nginx/sites-available/default':
    ensure  => 'absent',
    notify  => Service['nginx'],
    require => Package['nginx'],
  }
  exec { 'puppet module install rtyler/jenkins':
    path   => '/usr/bin:/usr/sbin:/bin',
    onlyif => 'test `puppet module list | grep rtyler-jenkins | wc -l` -eq 0',
  }

  # jenkins settings
  include jenkins
  $jenkins_home = '/var/lib/jenkins'
  $jenkins_plugins = ['jenkins-tracker', 'instant-messaging', 'ircbot',
                      'token-macro', 'github-api', 'github-oauth', 'github',
                      'git', 'git-chooser-alternative', 'greenballs',
                      'mailer', 'build-pipeline-plugin', 'git-parameter',
                      'ruby-runtime', 'jquery', 'jquery-ui', 'ghprb',
                      'javadoc', 'subversion', 'translation', 'ant', 'cvs',
                      'external-monitor-job', 'git-client', 'ldap',
                      'maven-plugin', 'pam-auth', 'parameterized-trigger',
                      'ssh-credentials', 'ssh-slaves', 'postbuild-task',
                      'scm-sync-configuration', 'git-notes', 'credentials',
                      'shiningpanda']
  user { 'jenkins':
    ensure     => 'present',
    managehome => true,
    home       => '/var/lib/jenkins',
    shell      => '/bin/bash',
  }
  jenkins::plugin {
    $jenkins_plugins : ;
  }
  package { 'fpm':
    ensure   => 'installed',
    provider => 'gem',
    require  => Package['ruby1.9.1-dev'],
  }
  package { 'puppet-lint':
    ensure   => 'installed',
    provider => 'gem',
    require  => Package['ruby1.9.1-dev'],
  }
  file { "${jenkins_home}/.ssh":
    ensure  => 'directory',
    notify  => Service['jenkins'],
    require => Class['jenkins::package'],
    owner   => 'jenkins',
  }
  file { '/var/deploys':
    ensure  => 'directory',
    notify  => Service['jenkins'],
    require => Class['jenkins::package'],
    owner   => 'jenkins',
  }
  file { "${jenkins_home}/.ssh/config":
    ensure  => 'present',
    notify  => Service['jenkins'],
    source  => "${ciroot}/jenkins/ssh/config",
    require => Class['jenkins::package'],
    owner   => 'jenkins',
  }
  file { "${jenkins_home}/.ssh/wakemakin-jenkins-backup-deploy":
    ensure  => 'present',
    notify  => Service['jenkins'],
    source  => "${ciroot}/jenkins/ssh/wakemakin-jenkins-backup-deploy",
    require => Class['jenkins::package'],
    owner   => 'jenkins',
    mode    => '0400',
  }
  file { "${jenkins_home}/.ssh/faro-api-deploy":
    ensure  => 'present',
    notify  => Service['jenkins'],
    source  => "${ciroot}/jenkins/ssh/faro-api-deploy",
    require => Class['jenkins::package'],
    owner   => 'jenkins',
    mode    => '0400',
  }
  file { "${jenkins_home}/.ssh/wakemakin-ci-deploy":
    ensure  => 'present',
    notify  => Service['jenkins'],
    source  => "${ciroot}/jenkins/ssh/wakemakin-ci-deploy",
    require => Class['jenkins::package'],
    owner   => 'jenkins',
    mode    => '0400',
  }
  #freight settings
  file { '/etc/freight.conf':
    ensure  => 'present',
    source  => "${ciroot}/freight/freight.conf",
    owner   => 'jenkins',
  }
  file { '/etc/apt/trusted.gpg.d/rcrowley.gpg':
    ensure  => 'present',
    source  => "${ciroot}/freight/rcrowley.gpg",
    owner   => 'jenkins',
  }
  file { '/var/lib/freight':
    ensure  => 'directory',
    owner   => 'jenkins',
    group   => 'www-data',
    mode    => '0755',
    recurse => true,
  }
  file { '/var/cache/freight':
    ensure  => 'directory',
    owner   => 'jenkins',
    group   => 'www-data',
    mode    => '0755',
    recurse => true,
  }
  apt::source { 'freight_repo':
    location          => 'http://packages.rcrowley.org',
    release           => 'precise',
    repos             => 'main',
    required_packages => 'debian-keyring debian-archive-keyring',
    include_src       => false
  }
  package { 'freight':
    ensure => 'installed',
  }
}
