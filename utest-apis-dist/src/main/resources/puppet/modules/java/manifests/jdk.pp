class java::jdk {

  include java
  
  package { $java::jdk_package :
    ensure => installed
  }

}
