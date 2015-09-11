# == Class: sentry::service
#
# This class is a wrapper to better handle different Linux distributions.
# Debian and related systems will use Supervisord to handle Sentry processes,
# while RedHat and related systems will use systemd.
class sentry::service {

  # note: we inspect the sentry::params value because there's no real reason
  # to pass this parameter up into sentry::init.  This is not something
  # likely to be overridden.
  class { "sentry::service::${sentry::params::daemonize}": }

  if $sentry::wsgi {
    class { 'sentry::service::wsgi': }
  }
}
