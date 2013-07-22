# /etc/puppet/modules/ci_tools/manifests/init.pp:
class ci_tools {
  $ciroot = '/etc/puppet/modules/ci_tools'
  $jenkins_home = '/var/lib/jenkins'
  exec { 'apt-update':
    command => '/usr/bin/apt-get update'
  }
  Exec['apt-update'] -> Package <| |>
  user { 'jenkins':
    ensure     => 'present',
    managehome => true,
    home       => '/var/lib/jenkins',
    shell      => '/bin/bash',
  }
  include jenkins
  $ci_things = ['nginx', 'reprepro', 'python-virtualenv',
                'rake', 'ruby']
  package { $ci_things:
    ensure  => 'installed',
  }
  service { 'nginx':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    require    => Package['nginx'],
  }
  file { '/etc/nginx/sites-available/jenkins':
    ensure  => 'present',
    notify  => Service['nginx'],
    source  => "${ciroot}/nginx/sites-available/jenkins",
    mode    => '0644',
    require => Package['nginx'],
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
  $jenkins_plugins = ['jenkins-tracker', 'instant-messaging', 'ircbot',
                      'token-macro', 'github-api', 'github-oauth', 'github',
                      'git', 'git-chooser-alternative', 'greenballs',
                      'mailer', 'build-pipeline-plugin', 'git-parameter',
                      'ruby-runtime', 'jquery', 'jquery-ui', 'ghprb',
                      'javadoc', 'subversion', 'translation', 'ant', 'cvs',
                      'external-monitor-job', 'git-client', 'ldap',
                      'maven-plugin', 'pam-auth', 'parameterized-trigger',
                      'ssh-credentials', 'ssh-slaves',
                      'scm-sync-configuration', 'git-notes', 'credentials',
                      'shiningpanda']
  jenkins::plugin {
    $jenkins_plugins : ;
  }
  file { "${jenkins_home}/.ssh":
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
  file { '${jenkins_home}/.ssh/faro-api-deploy':
    ensure  => 'present',
    notify  => Service['jenkins'],
    source  => "${ciroot}/jenkins/ssh/faro-api-deploy",
    require => Class['jenkins::package'],
    owner   => 'jenkins',
    mode    => '0400',
  }
  file { '${jenkins_home}/.ssh/faro-api-deploy':
    ensure  => 'present',
    notify  => Service['jenkins'],
    source  => "${ciroot}/jenkins/ssh/wakemakin-ci-deploy",
    require => Class['jenkins::package'],
    owner   => 'jenkins',
    mode    => '0400',
  }
}
