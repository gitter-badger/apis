$java_vendor = "openjdk"

$java_major_version = "7"

$newrelic_license = $cfn_newrelic_key

$www_dir = "/var/lib/www"

$www_html_dir = "${www_dir}/html"

class common {

  include ntp
  
  include syslog
  
  # other libraries/packages needed by the application code
  # be sure to use the Ubuntu package names (not MacOS/homebrew)

  $other_packages = [ "mysql-client" ]
  
  package { $other_packages :
    ensure => present
  }
  
  group { "utest":
    gid    => 10000,
  }

  group { "testgrp":
    gid    => 20000,
  }

  user { "utest":
    groups => [ 'utest', 'adm', 'syslog', 'puppet' ],
    gid => '10000',
    uid => '10000',
    comment => 'uTest power user',
    ensure => 'present',
    managehome => 'true',
    shell => '/bin/bash'
  }

  file { "/home/utest/.inputrc" :
    require => User["utest"],
    content => "set bell-style none\n",
    owner => "utest",
    mode => 0644
  }

  user { "testgrp":
    groups => [ 'testgrp', 'adm', 'syslog', 'puppet' ],
    gid => '20000',
    uid => '20000',
    comment => 'uTest read-only user',
    ensure => 'present',
    managehome => 'true',
    shell => '/bin/bash'
  }

  file { "/home/testgrp/.inputrc" :
    require => User["utest"],
    content => "set bell-style none\n",
    owner => "testgrp",
    mode => 0644
  }

  file { "/home/utest/.ssh/":
    require => User['utest'],
    ensure => directory,
    owner  => "utest",
    group  => "utest",
    mode   => "700",
  }

  file { "/home/testgrp/.ssh/":
    require => User['testgrp'],
    ensure => directory,
    owner  => "testgrp",
    group  => "testgrp",
    mode   => "700",
  }

  file { "/home/utest/.ssh/authorized_keys":
    require => User['utest'],
    ensure => present,
    owner  => "utest",
    group  => "utest",
    mode   => "700",
    source => "puppet:///dist/users/utest_keys"
  }

  file { "/home/testgrp/.ssh/authorized_keys":
    require => User['testgrp'],
    ensure => present,
    owner  => "testgrp",
    group  => "testgrp",
    mode   => "700",
    source => "puppet:///dist/users/testgrp_keys"
  }

  # Install utest user SUDO

  file { "/etc/sudoers.d/100-utest":
    require => User['utest'],
    ensure => file,
    owner  => "root",
    group  => "root",
    mode   => "440",
    source => "puppet:///dist/users/sudoers.d/utest"
  }

}

class cc inherits common {

  include java::jdk
  
  file { [ "/var/log/hosts", "/var/log/consolidated"  ] :
    ensure => directory,
    owner => "syslog",
    group => "adm",
    mode => 0755,
    notify => Class['syslog']
  }

}

class fe inherits common {

  include java::jre

  class { "tomcat" : }

  file { "/etc/apache2/ssl":
    recurse => true,
    ensure => directory,
    owner  => "root",
    group  => "root",
    mode   => "700",
    source => "puppet:///dist/ssl",
    require => Package["apache2"],
  }

  file { [ $www_dir, $www_html_dir ] :
    ensure => directory,
    owner => "root",
    group => "root",
    mode =>  0755
  }

  file { "${www_html_dir}/index.html" :
    owner => "root",
    group => "root",
    mode => 0644,
    content => "<html><head><meta http-equiv=\"refresh\" content=\"0; url=http://utest.com/\"></head><body></body></html>",
    require => File[$www_dir, $www_html_dir],
  }
  
  apache2_mod_jk::loadmodule { "rewrite" : }
  
  apache2_mod_jk::loadmodule { "ssl" : }
  
  apache2_mod_jk::vhost { "/etc/apache2/sites-available/default" :
    document_root => $www_html_dir,
  }

  class { "apis" :
    db1_address => $cfn_db1_address,
    db_name => $cfn_db_name,
    db_username => $cfn_db_username,
    db_password => $cfn_db_password,
    platform_rest_url => $cfn_platform_rest_url,
    stack_name => $cfn_stack_name,
  }
  
}

node /^cc\-.*/ {

  syslog::conf { "/etc/rsyslog.d/99-cc.conf" :
    conf_template => "syslog/server.conf.erb"
  }

  include cc
  
}

node /^fe\-.*/ {

  syslog::conf { "/etc/rsyslog.d/99-fe.conf" :
    conf_template => "syslog/client.conf.erb",
    loghost => $cfn_cc1_address
  }

  include fe
  
}

