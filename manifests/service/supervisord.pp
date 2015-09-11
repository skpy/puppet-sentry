# == Class: sentry::service::supervisord
#
# This class is meant to be called from sentry.
# It ensures the service is running via Supervisord
#
class sentry::service::supervisord
{
  $command = join([
    "${sentry::path}/virtualenv/bin/sentry",
    "--config=${sentry::path}/sentry.conf.py"
  ], ' ')

  Supervisord::Program {
    ensure          => present,
    directory       => $sentry::path,
    user            => $sentry::owner,
    autostart       => true,
    redirect_stderr => true,
  }

  supervisord::supervisorctl { 'sentry_reload':
    command     => 'reload',
    refreshonly => true,
  }

  if $sentry::service_restart {
    $notify_target = Supervisord::Supervisorctl['sentry_reload']
  } else {
    $notify_target = undef
  }

  if ! $sentry::wsgi {
    # if not using mod_wsgi then have Supervisord manage Sentry
    supervisord::program { 'sentry-http':
      command => "${command} start http",
      notify  => $notify_target,
      before  => Supervisord::Program['sentry-worker'],
    }
  }

  supervisord::program { 'sentry-worker':
    command => "${command} celery worker -B",
    notify  => $notify_target,
  }

}
