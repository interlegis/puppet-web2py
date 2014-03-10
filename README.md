puppet-web2py
=============

Web2Py module for Puppet. 

Configures web2py with Nginx and FastCGI. Using jfryman/puppet-nginx and camptocamp/puppet-archive.

Simple Usage:


    class { "web2py":
      sslcert => '/etc/ssl/certs/myapp.crt',
      sslkey => '/etc/ssl/private/myapp.key',
      defaultApp => 'myapp',
    }


Default Values:

    source => 'http://www.web2py.com/examples/static/web2py_src.zip'
    target = '/opt'
    vhost  = 'web2py'
    initialPw = 'password'
    sslcert = Required.
    sslkey = Required.
    defaultApp = 'admin'
    
