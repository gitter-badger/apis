class apis(
  $catalina_base = "/var/lib/tomcat7",
  $catalina_home = "/usr/share/tomcat7",
  $platform_rest_url,
  $db1_address,
  $db_name,
  $db_username,
  $db_password,
  $engine_name = "Catalina",
  $hostname = "localhost",
  $stack_name
  ) {

  file { "${catalina_base}/lib/apis.application.properties" :
    mode => 0644,
    owner => "root",
    group => "root",
    content => template("apis/apis.application.properties.erb"),
    notify => Service["tomcat7"],
    require => Package["tomcat7"],
  }

  file { "${catalina_base}/lib/apis-logback.xml" :
    mode => 0644,
    owner => "root",
    group => "root",
    content => template("apis/apis-logback.xml.erb"),
    notify => Service["tomcat7"],
    require => Package["tomcat7"],
  }

  file { "${catalina_base}/webapps/apis.war" :
    mode => 0644,
    owner => "root",
    group => "root",
    source => "puppet:///modules/apis/apis-authorization-server-war-latest.war",
    notify => Service["tomcat7"],
    require => Package["tomcat7"],
    }

  }
