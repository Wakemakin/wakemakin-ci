class ci_tools {
	exec { "apt-update":
	    command => "/usr/bin/apt-get update"
	}

	Exec["apt-update"] -> Package <| |>

	user { "jenkins":
		ensure     => "present",
		managehome => true,
		home       => "/var/lib/jenkins",
		shell	   => "/bin/bash",
	}

	include jenkins
	$ci_things = [ "nginx", "reprepro", "python-virtualenv",
		       "rake", "ruby" ]

	package { $ci_things: 
		ensure  => "installed",
	}


	service { "nginx":
		ensure     => "running",
		enable     => "true",
		hasrestart => "true",
		require    => Package["nginx"],
	}

	file { "/etc/nginx/sites-available/jenkins":
		notify  => Service["nginx"],
		ensure  => "present",
		source  => "/etc/puppet/modules/ci_tools/nginx/sites-available/jenkins",
		mode    => 644,
		require => Package["nginx"],
	}

	file { "/etc/nginx/sites-enabled/jenkins":
		notify  => Service["nginx"],
		ensure  => "link",
		target  => "/etc/puppet/modules/ci_tools/nginx/sites-available/jenkins",
		require => Package["nginx"],
	}

	file { "/etc/nginx/sites-available/default":
		notify  => Service["nginx"],
		ensure  => "absent",
		require => Package["nginx"],
	}

	exec { "puppet module install rtyler/jenkins":
		path   => "/usr/bin:/usr/sbin:/bin",
		onlyif => "test `puppet module list | grep rtyler-jenkins | wc -l` -eq 0",
	}

	$jenkins_plugins = [ "jenkins-tracker", "instant-messaging", "ircbot", "token-macro",
			     "github-api", "github-oauth", "github", "git", "git-chooser-alternative",
		             "greenballs", "mailer", "build-pipeline-plugin", "git-parameter", "ruby-runtime",
			     "jquery", "jquery-ui", "ghprb", "javadoc", "subversion", "translation",
			     "ant", "cvs", "external-monitor-job", "git-client", "ldap", "maven-plugin",
			     "pam-auth", "parameterized-trigger", "ssh-credentials", "ssh-slaves",
			     "scm-sync-configuration", "git-notes", "credentials", "shiningpanda" ]

	jenkins::plugin {
		$jenkins_plugins : ;
	}

	file { "/var/lib/jenkins/.ssh":
		notify  => Service["jenkins"],
		ensure  => "directory",
		require => Class["jenkins::package"],
		owner	=> "jenkins",
	}

	file { "/var/lib/jenkins/.ssh/config":
		notify  => Service["jenkins"],
		ensure  => "present",
		source  => "/etc/puppet/modules/ci_tools/jenkins/ssh/config",
		require => Class["jenkins::package"],
		owner	=> "jenkins",
	}

	file { "/var/lib/jenkins/.ssh/wakemakin-jenkins-backup-deploy":
		notify  => Service["jenkins"],
		ensure  => "present",
		source  => "/etc/puppet/modules/ci_tools/jenkins/ssh/wakemakin-jenkins-backup-deploy",
		require => Class["jenkins::package"],
		owner	=> "jenkins",
		mode	=> 400,
	}

	file { "/var/lib/jenkins/.ssh/faro-api-deploy":
		notify  => Service["jenkins"],
		ensure  => "present",
		source  => "/etc/puppet/modules/ci_tools/jenkins/ssh/faro-api-deploy",
		require => Class["jenkins::package"],
		owner	=> "jenkins",
		mode	=> 400,
	}
}
