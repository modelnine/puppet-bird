# == Class: bird
#
# Install and configure bird
#
# === Parameters
#
# [*config_file_v4*]
#   Bird configuration file for IPv4.
#   Default: UNSET. (this value is a puppet source, example 'puppet:///modules/bgp/bird.conf').
#
# [*config_template_v4*]
#   Bird configuration template for IPv4.
#   Default: UNSET. (this value is a template source, it will be passed into the template() function).
#
# [*daemon_name_v6*]
#   The service name used by puppet ressource
#   Default: bird6
#
# [*daemon_name_v4*]
#   The service name used by puppet ressource
#   Default: bird
#
# [*config_path_v6*]
#   The full path of the v6 configuration file
#   Default: /etc/bird/bird6.conf
#
# [*config_path_v4*]
#   The full path of the v4 configuration file
#   Default: /etc/bird/bird.conf
#
# [*enable_v6*]
#   Boolean for enable IPv6 (install bird6 package)
#   Default: true
#
# [*manage_conf*]
#   Boolean, global parameter to disable or enable mangagment of bird configuration files.
#   Default: true
#
# [*manage_service*]
#   Boolean, global parameter to disable or enable mangagment of bird service.
#   Default: true
#
# [*service_v6_ensure*]
#   Bird IPv6 daemon ensure (shoud be running or stopped).
#   Default: running
#
# [*service_v6_enable*]
#   Boolean, enabled param of Bird IPv6 service (run at boot time).
#   Default: true
#
# [*service_v4_ensure*]
#   Bird IPv4 daemon ensure (shoud be running or stopped).
#   Default: running
#
# [*service_v4_enable*]
#   Boolean, enabled param of Bird IPv4 service (run at boot time).
#   Default: true
#
# [*config_file_v6*]
#  Bird configuration file for IPv6.
#  Default: UNSET. (this value is a puppet source, example 'puppet:///modules/bgp/bird6.conf').
#
# [*config_template_v6*]
#   Bird configuration template for IPv6.
#   Default: UNSET. (this value is a template source, it will be passed into the template() function).
#
# === Examples
#
#  class { 'bird':
#    enable_v6       => true,
#    config_file_v4  => 'puppet:///modules/bgp/ldn/bird.conf',
#    config_file_v6  => 'puppet:///modules/bgp/ldn/bird6.conf',
#  }
#
# === Authors
#
# Sebastien Badia <http://sebastien.badia.fr/>
# Lorraine Data Network <http://ldn-fai.net/>
#
# === Copyright
#
# Copyleft 2013 Sebastien Badia
# See LICENSE file
#
class bird (
  String $daemon_name_v4     = $bird::params::daemon_name_v4,
  String $package_name_v4    = $bird::params::package_name_v4,
  String $package_ensure_v4  = installed,
  String $config_path_v4     = $bird::params::config_path_v4,
  String $config_file_v4     = nil,
  String $config_template_v4 = nil,
  String $config_v4          = nil,
  Boolean $enable_v6         = false,
  Boolean $manage_conf       = false,
  Boolean $manage_service    = false,
  String $service_v4_ensure  = running,
  Boolean $service_v4_enable = true,
  String $service_v6_ensure  = running,
  Boolean $service_v6_enable = true,
  String $daemon_name_v6     = $bird::params::daemon_name_v6,
  String $package_name_v6    = $bird::params::package_name_v6,
  String $package_ensure_v6  = installed,
  String $config_path_v6     = $bird::params::config_path_v6,
  String $config_file_v6     = nil,
  String $config_template_v6 = nil,
  String $config_v6          = nil,
) inherits bird::params {

  validate_bool($manage_conf)
  validate_bool($manage_service)

  validate_bool($enable_v6)
  validate_bool($service_v6_enable)
  validate_bool($service_v4_enable)

  validate_re($service_v6_ensure,['^running','^stopped'])
  validate_re($service_v4_ensure,['^running','^stopped'])

  package {
    $package_name_v4:
      ensure => $package_ensure_v4;
  }

  if $manage_service == true {
    service {
      $daemon_name_v4:
        ensure     => $service_v4_ensure,
        enable     => $service_v4_enable,
        hasrestart => false,
        restart    => '/usr/sbin/birdc configure',
        hasstatus  => false,
        pattern    => $daemon_name_v4,
        require    => Package[$package_name_v4];
    }
  }

  if $manage_conf == true {
    if $config_file_v4 != nil {
      file {
        $config_path_v4:
          ensure  => file,
          source  => $config_file_v4,
          owner   => bird,
          group   => bird,
          mode    => '0640',
          notify  => Service[$daemon_name_v4],
          require => Package[$package_name_v4];
      }
    } elsif $config_template_v4 != nil {
      file {
        $config_path_v4:
          ensure  => file,
          content => template($config_template_v4),
          owner   => bird,
          group   => bird,
          mode    => '0640',
          notify  => Service[$daemon_name_v4],
          require => Package[$daemon_name_v4];
      }
    } elsif $config_v4 != nil {
      file {
        $config_path_v4:
          ensure  => file,
          content => $config_v4,
          owner   => bird,
          group   => bird,
          mode    => '0640',
          notify  => Service[$daemon_name_v4],
          require => Package[$daemon_name_v4];
      }
    } else {
      fail("either config_file_v4 or config_template_v4 or config_v4 parameter must be set")
    }
  } # manage_conf

  if $enable_v6 == true {
    if $package_name_v4 != $package_name_v6 {
      package {
        $package_name_v6:
          ensure => $package_ensure_v6;
      }
    }

    if $manage_service == true {
      service {
        $daemon_name_v6:
          ensure     => $service_v6_ensure,
          enable     => $service_v6_enable,
          hasrestart => false,
          restart    => '/usr/sbin/birdc6 configure',
          hasstatus  => false,
          pattern    => $daemon_name_v6,
          require    => Package[$package_name_v6];
      }
    }

    if $manage_conf == true {
      if $config_file_v6 != nil {
        file {
          $config_path_v6:
            ensure  => file,
            source  => $config_file_v6,
            owner   => bird,
            group   => bird,
            mode    => '0640',
            notify  => Service[$daemon_name_v6],
            require => Package[$package_name_v6];
          }
      } elsif $config_template_v6 != nil {
        file {
          $config_path_v6:
            ensure  => file,
            content => template($config_template_v6),
            owner   => bird,
            group   => bird,
            mode    => '0640',
            notify  => Service[$daemon_name_v6],
            require => Package[$package_name_v6];
        }
      } elsif $config_v6 != nil {
        file {
          $config_path_v6:
            ensure  => file,
            content => $config_v6,
            owner   => bird,
            group   => bird,
            mode    => '0640',
            notify  => Service[$daemon_name_v6],
            require => Package[$package_name_v6];
        }
      } else {
        fail("either config_file_v6 or config_template_v6 or config_v6 parameter must be set")
      }
    } # manage_conf
  } # enable_v6

} # Class:: bird
