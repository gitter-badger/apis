class java::jre {

  include java

  package { $java::jre_package :
    ensure => installed
  }

}
