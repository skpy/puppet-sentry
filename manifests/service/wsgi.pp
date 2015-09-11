# == Class: sentry::service::wsgi
#
# This class is meant to be called from sentry.
# It ensures that an Apache mod_wsgi vhost is configured
# and activated for Sentry.
#
class sentry::service::wsgi {
  # this is a null declaration to ensure that the Apache module
  # doesn't try to helpfully create the docroot.
  file{ $sentry::venv: }

  include apache::mod::wsgi

  $config = merge(
    $sentry::params::wsgi_config_default,
    $sentry::wsgi_config
  )

  $python = regsubst( $::python_version, '(\d)\.(\d).+', 'python\1.\2' )
  $python_path = "${sentry::path}/virtualenv/lib/${python}/site-packages/"

  $wsgi_options_hash = {
      user         => $sentry::user,
      group        => $sentry::group,
      processes    => $config['wsgi_processes'],
      threads      => $config['wsgi_threads'],
      display-name => 'wsgi_sentry',
      # find a way to make the next line work with different Pythons
      python-path  => $python_path,
  }

  if $sentry::ssl {
    include apache::mod::ssl
    $port = '443'
  } else {
    $port = '80'
  }

  #lint:ignore:arrow_alignment
  apache::vhost { 'sentry':
    access_log_file             => 'sentry.log',
    access_log_format           => 'combined',
    custom_fragment             => 'RewriteEngine on\nRewriteRule ^/dsn_list$ /dsn_list.txt',
    docroot                     => $sentry::path,
    error_log_file              => 'sentry-e.log',
    port                        => $port,
    servername                  => $sentry::host,
    ssl                         => $sentry::ssl,
    ssl_ca                      => $sentry::ssl_ca,
    ssl_chain                   => $sentry::ssl_chain,
    ssl_cert                    => $sentry::ssl_cert,
    ssl_key                     => $sentry::ssl_key,
    wsgi_daemon_process         => 'wsgi_sentry',
    wsgi_daemon_process_options => $wsgi_options_hash,
    wsgi_pass_authorization     => 'On',
    wsgi_process_group          => 'wsgi_sentry',
    wsgi_script_aliases         => { '/' => "${sentry::path}/app_init.wsgi", },
  }
  #lint:endignore

  file { "${sentry::path}/app_init.wsgi":
    ensure  => present,
    content => template('sentry/app_init.wsgi.erb'),
  }

}
