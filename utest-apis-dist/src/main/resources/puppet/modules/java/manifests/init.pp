class java {

  case $java_vendor {
    "oracle" : {
      fail("TODO: Figure out how to install Oracle JDK")
    }
    "openjdk" : {
      case $java_major_version {
        "6" : {
          $jdk_package = "openjdk-6-jdk"
          $jre_package = "openjdk-6-jre"
        }
        "7" : {
          $jdk_package = "openjdk-7-jdk"
          $jre_package = "openjdk-7-jre"
        }
        default : {
          fail("Unrecognized or missing value for 'java_major_version'")
        }
      }
    }
    default : {
      fail("Unrecognized or missing value for 'java_vendor'")
    }

  }

}
