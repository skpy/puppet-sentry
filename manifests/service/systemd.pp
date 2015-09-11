# == Class: sentry::service::systemd
#
# This class is meant to be called from sentry.
# It ensures the service is running via systemd
#
class sentry::service::systemd
{

  # set local variables for use in the .service files
  $user  = $sentry::user
  $group = $sentry::group
  $venv  = "${sentry::path}/virtualenv"

  exec { 'enable-sentry-services':
    command     => '/sbin/systemctl daemon-reload',
    refreshonly => true,
    path        => '/bin:/sbin',
  }

  if ! $sentry::wsgi {
    # if mod_wsgi is not enabled, have systemd start Sentry
    file { '/etc/systemd/system/sentry.service':
      ensure  => present,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      content => template('sentry/sentry.service.erb'),
      notify  => Exec['enable-sentry-services'],
    }

    service { 'sentry-celery':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      require    => File['/etc/systemd/system/sentry.service'],
    }
  }

  # the Sentry Celery workers will be run by systemd
  # regardless of whether we're using mod_wsgi or not
  file { '/etc/systemd/system/sentry-worker.service':
    ensure  => present,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    content => template('sentry/sentry-worker.service.erb'),
    notify  => Exec['enable-sentry-services'],
  }


  service { 'sentry-worker':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => File['/etc/systemd/system/sentry-worker.service'],
  }

}
