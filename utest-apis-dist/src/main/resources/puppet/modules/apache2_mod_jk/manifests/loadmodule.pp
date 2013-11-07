define apache2_mod_jk::loadmodule () {

  include apache2_mod_jk
  
  exec { "/usr/sbin/a2enmod $name" :
    unless => "/bin/readlink -e /etc/apache2/mods-enabled/${name}.load",
    notify => Service[apache2]
  }
}
