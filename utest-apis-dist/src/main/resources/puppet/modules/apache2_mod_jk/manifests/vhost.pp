define apache2_mod_jk::vhost (
  $document_root,
  $vhost_name = "*",
  $port = 80,
  $sslport = 443,
  $jvm_route = "jvm1",
  $vhost_conf_template = 'apache2_mod_jk/vhost.conf.erb',
  $vhost_conf_file = $title) {
    
    include apache2_mod_jk
    
    file { $vhost_conf_file :
      content => template($vhost_conf_template),
      owner => 'root',
      group => 'root',
      mode => 0644,
      require => Package['apache2'],
      notify => Service['apache2']
    }
    
  }
