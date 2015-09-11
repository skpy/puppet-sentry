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

      $daemonize = 'supervisord'
    }
    'RedHat': {
      if $::operatingsystemmajrelease < 7 {
        fail ('RedHat and related hosts require systemd, which is only available on version 7 or above.')
      }

      $packages = [
        'libffi-devel',
        'openssl-devel',
        'libxml2-devel',
        'libxslt-devel',
        'zlib-devel',
      ]

      $mysql_packages = [
        'mariadb-devel',
      ]

      $postgres_packages = [
        'postgresql-devel'
      ]

      $daemonize = 'systemd'
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
  $version         = undef  # indicates latest pypi version
  $git_revision    = 'master'
  $git_url         = 'git+https://github.com/getsentry/sentry.git'
  $timeout         = 1800

  # Config params
  $password_hash = 'pbkdf2_sha256$20000$9tjS6wreTjar$oAdyvcOd8HCMuBpxdyvv2Cg7xz6Ee1IVz30zYUA46Wg='
  $secret_key    = fqdn_rand_string(50)
  $user          = 'admin'
  $email         = 'root@localhost'
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
  $memcached_config_default = {
    'host' => 'localhost',
    'port' => 11211,
  }
  $redis_config_default = {
    'host' => 'localhost',
    'port' => 6379,
  }

  $ssl           = false
  $ssl_ca        = undef
  $ssl_chain     = undef
  $ssl_cert      = '/etc/pki/tls/certs/localhost.crt'
  $ssl_key       = '/etc/pki/tls/private/localhost.key'

  $wsgi = false
  $wsgi_default = {
    'wsgi_processes' => 1,
    'wsgi_threads'   => 15,
  }
}
