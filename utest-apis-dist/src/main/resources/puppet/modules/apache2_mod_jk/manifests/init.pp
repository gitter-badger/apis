class apache2_mod_jk(
  $ajp_port = 8009,
  $jvm_route = "jvm1",
  $jk_conf_file = "/etc/apache2/mods-available/jk.conf",
  $workers_properties_file = "/etc/libapache2-mod-jk/workers.properties"
  ) {

  package { [ "apache2", "libapache2-mod-jk" ]  :
    ensure => installed,
  }

  service { "apache2" :
    ensure => running,
    enable => true,
  }

  file { $jk_conf_file :
    content => template("apache2_mod_jk/jk.conf.erb"),
    mode => 0644,
    owner => "root",
    group => "root",
    require => Package["apache2", "libapache2-mod-jk"],
    notify => Service["apache2"],
  }
  
  file { $workers_properties_file :
    content => template("apache2_mod_jk/workers.properties.erb"),
    mode => 0644,
    owner => "root",
    group => "root",
    require => Package["apache2", "libapache2-mod-jk"],
    notify => Service["apache2"],
  }

  }
