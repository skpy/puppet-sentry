# == Class: sentry::params

# This class is meant to be called from sentry.
# It sets variables according to platform.
#
class sentry::params
{
  # Platform params
  case $::osfamily {
    'Debian': {
      $packages = [
        # Next two needed by requests (w/ security) python library
        'libffi-dev',
        'libssl-dev',
        # Next three needed by lxml python library
        'libxml2-dev',
        'libxslt1-dev',
        'zlib1g-dev',
      ]

      $mysql_packages = [
        'libmysqlclient-dev',
      ]

      $postgres_packages = [
        'libpq-dev',
      ]
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

  # Install params
  $path            = '/srv/sentry'
  $owner           = 'sentry'
  $group           = 'sentry'
  $source_location = 'pypi'
  $version         = '7.7.0'
  $git_revision    = 'master'
  $git_url         = 'git+https://github.com/getsentry/sentry.git'
  $timeout         = 1800

  # Config params
  $password      = 'password'
  $secret_key    = 'bxXkluWCyi7vNDDALvCKOGCI2WEbohkpF9nVPnV6jWGB1grz5csT3g=='
  $email         = 'admin@localhost'
  $url           = 'http://localhost:9000'
  $host          = 'localhost'
  $port          = 9000
  # http://gunicorn-docs.readthedocs.org/en/latest/design.html#how-many-workers
  $workers       = ($::processorcount * 2) + 1
  $database      = 'sqlite'

  $database_config_default = {
    'name'     => 'sentry',
    'user'     => '',
    'password' => '',
    'host'     => 'localhost',
    'port'     => '',  # allow django to choose default port
  }
  $email_config_default = {
    'host'      => 'localhost',
    'port'      => 25,
    'user'      => '',
    'password'  => '',
    'use_tls'   => false,
    'from_addr' => $email,
  }
  $redis_config_default = {
    'host' => 'localhost',
    'port' => 6379,
  }
}
