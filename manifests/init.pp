#init.pp

class web2py ( $source     = 'http://www.web2py.com/examples/static/web2py_src.zip',
               $target     = '/opt',
               $vhost      = 'web2py',
               $initialPw  = 'password',
               $sslcert    = false,
               $sslkey     = false,
               $defaultApp = 'admin',
               ) {

  if ! defined(Package['unzip']) {
    package { 'unzip': ensure => 'present' }
  }

  file { $target:
    ensure => directory,
  }

  archive { $name:
    ensure => present,
    url    => $source,
    target => "$target",
    checksum => false,
    extension => inline_template("<%= source.rpartition('.')[2] %>"),
    require => [ Package['unzip'],
                 File[$target],
              ] ,
  }

  if ! defined (Class['nginx']) {
    class { 'nginx':
      manage_repo => false,
    }
  }

  file { "$target/web2py/fcgihandler.py":
    ensure => link,
    target => "$target/web2py/handlers/fcgihandler.py",
    require => Archive[$name],
  }

  exec { "create parameters file":
    cwd => "$target/web2py",
    command => "/usr/bin/python -c \"from gluon.main import save_password; save_password('$initialPw',443)\"",
    creates => "$target/web2py/parameters_443.py",
  }
 
  file { "/etc/init.d/web2py":
    owner => root, group => root, mode => '755',
    content => template('web2py/web2py_init.erb'),
    require => File["$target/web2py/fcgihandler.py"],
  }

  service { "web2py":
    ensure => running,
    require => File['/etc/init.d/web2py'],
  }
 
  if !$sslcert or !$sslkey {
    fail("You won't be able to access the administrative interface without specifying sslcert and sslkey variables.")
  } else {
    nginx::resource::vhost { "$vhost":
      www_root => "$target/web2py",
      location_cfg_append => { 'rewrite' => '^ https://$server_name$request_uri? permanent' },
    }

    nginx::resource::vhost { "web2py":
      www_root => "$target/web2py/",
      fastcgi => "unix:/tmp/fcgi.sock",
      ssl => true,
      ssl_cert => $sslcert,
      ssl_key => $sslkey,
      ssl_port => 443,
    }
  }

  file { "$target/web2py/routes.py":
    owner => root, group => root, mode => '755',
    content => template('web2py/routes.py.erb'),
    notify => Service["web2py"],
  }



}
