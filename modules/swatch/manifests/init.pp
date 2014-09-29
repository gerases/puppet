class swatch {
  package { 'swatch': ensure => installed }

  $cat_command="/bin/cat /etc/swatch/swatch_global.cnf /etc/swatch/swatch.local.cnf >> /etc/swatch/swatch.cnf" 
  $target_dir='/etc/swatch'
  $target_file='/etc/swatch/swatch.cnf'

  file { $target_dir:
    ensure => 'directory',
  }

  exec {'force-regen':
    command => $cat_command,
    creates => $target_file,
    require => [File['/etc/swatch/swatch.local.cnf'], File['/etc/swatch/swatch_global.cnf']],
  }

  exec {'append-to-swatch-cnf':
    command => "/usr/bin/test -f ${target_file} && /bin/rm ${target_file}; ${cat_command}",
    refreshonly => true,
    logoutput => true,
  }

  file { '/etc/swatch/swatch.local.cnf':
    ensure => 'present',
    source => ["puppet:///modules/swatch/swatch.${::hostname}.cnf", 'puppet:///modules/swatch/swatch_default_local.cnf' ],
    notify => Exec['append-to-swatch-cnf'],
    require => File[$target_dir]
  }

  file { '/etc/swatch/swatch_global.cnf':
    ensure => 'present',
    source => 'puppet:///modules/swatch/swatch_global.cnf',
    notify => Exec['append-to-swatch-cnf'],
    require => File[$target_dir]
  }
}
