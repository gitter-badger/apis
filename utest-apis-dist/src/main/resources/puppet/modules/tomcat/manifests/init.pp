class tomcat(
  $ajp_port = 8009,
  $jvm_route = "jvm1",
  $max_threads = 150,
  $min_spare_threads = 4,
  $catalina_opts = "-Xmx1536m -XX:MaxPermSize=256m -Xms512m -Djsse.enableSNIExtension=false",
  $catalina_base = "/var/lib/tomcat7",
  $catalina_home = "/usr/share/tomcat7"
  ) {

  package { [ "tomcat7", "libtcnative-1" ] :
    ensure => installed,
  }

  service { "tomcat7" :
    ensure => running,
    require => [ Package["tomcat7", "libtcnative-1"], User["tomcat7"] ],
  }

  group { "tomcat7" :
    ensure => present,
  }

  user { "tomcat7" :
    ensure => present,
    groups => [ "tomcat7" ],
    shell => "/bin/false",
  }

  # logging configuration that replaces juli logging with log4j so that we
  # can send everything to syslog, per http://tomcat.apache.org/tomcat-7.0-doc/logging.html#Using_Log4j

  file { "${catalina_base}/lib" :
    ensure => directory,
    owner => "tomcat7",
    group => "tomcat7",
    mode => 0755,
    require => Package["tomcat7"],
    notify => Service["tomcat7"],
  }
  
  file { "${catalina_base}/lib/log4j.properties" :
    owner => "root",
    group => "root",
    content => template("tomcat/log4j.properties.erb"),
    mode => 0644,
    require => [ Package["tomcat7"], File["${catalina_base}/lib"] ],
    notify => Service["tomcat7"],
  }

  file { "${catalina_base}/conf/logging.properties" :
    ensure => absent,
    require => Package["tomcat7"],
    notify => Service["tomcat7"],
  }

  file { "${catalina_home}/lib/tomcat-juli.jar" :
    ensure => absent
  }

  file { "${catalina_base}/bin/tomcat-juli.jar" :
    ensure => link,
    target => "${catalina_home}/lib/tomcat-juli-7.0.26.jar",
    require => [ Package["tomcat7"], File["${catalina_home}/lib/tomcat-juli-7.0.26.jar", "${catalina_base}/bin" ] ],
    notify => Service["tomcat7"],
  }

  file { "${catalina_home}/lib/tomcat-juli-adapters-7.0.26.jar" :
    source => "puppet:///modules/tomcat/tomcat-juli-adapters-7.0.26.jar",
    owner => "root",
    group => "root",
    mode => 0644,
    require => Package["tomcat7"],
    notify => Service["tomcat7"],
  }

  file { "${catalina_home}/lib/log4j-1.2.17.jar" :
    source => "puppet:///modules/tomcat/log4j-1.2.17.jar",
    owner => "root",
    group => "root",
    mode => 0644,
    require => Package["tomcat7"],
    notify => Service["tomcat7"],
  }

  file { "${catalina_home}/lib/tomcat-juli-7.0.26.jar" :
    source => "puppet:///modules/tomcat/tomcat-juli-7.0.26.jar",
    owner => "root",
    group => "root",
    mode => 0644,
    require => Package["tomcat7"],
    notify => Service["tomcat7"],
  }

  # server.xml that contains only the ajp listener

  file { "/etc/tomcat7/server.xml" :
    content => template("tomcat/server.xml.erb"),
    owner => "root",
    group => "tomcat7",
    mode => 0644,
    require => [ Package["tomcat7"], User["tomcat7"] ],
    notify => Service["tomcat7"],
  }

  # runtime options for tomcat

  file { "${catalina_base}/bin" :
    ensure => directory,
    owner => "tomcat7",
    group => "tomcat7",
    mode => 0755,
    require => Package["tomcat7"],
    notify => Service["tomcat7"],
  }

  file { "${catalina_base}/bin/setenv.sh" :
    content => template("tomcat/setenv.sh.erb"),
    owner => "root",
    group => "root",
    mode => 0644,
    require => [ File["${catalina_base}/bin"], Package["tomcat7"] ],
    notify => Service["tomcat7"],
  }

  # get rid of stuff we don't use

  file { "${catalina_base}/conf/tomcat-users.xml" :
    ensure => absent,
  }

  file { "${catalina_base}/webapps/ROOT" :
    ensure => absent,
    force => true,
  }

}
