# /etc/apache2/sites-available/contribute.foo.com

<VirtualHost *:80>
    
    # Basic configuration
    ServerName contribute.foo.com
    ServerAdmin admin@foo.com
    
    # Trac's configuration
    <Location />
        SetHandler mod_python
        PythonHandler trac.web.modpython_frontend
        PythonOption TracEnv /var/lib/trac/foo
        PythonOption TracUriRoot /
    </Location>
    <Location /login>
        AuthType Digest
        AuthName "Foo"
        AuthUserFile /var/lib/svn/foo/conf/dav_svn_passwd.digest
        BrowserMatch "MSIE" AuthDigestEnableQueryStringHack=On
        Require valid-user
    </Location>
    
    # Log configuration
    <FilesMatch \.(jpg|gif|png)$>
        SetEnvIfNoCase Referer "^http://contribute.foo.com/" local_referer=1
    </FilesMatch>
    CustomLog ${APACHE_LOG_DIR}/foo.com/contribute_access.log combined env=!local_referer
    ErrorLog ${APACHE_LOG_DIR}/foo.com/contribute_error.log
    
</VirtualHost>

<VirtualHost *:80>
    ServerName trac.foo.com
    ServerAlias wiki.foo.com
    ServerAlias admin.foo.com
    ServerAlias discussions.foo.com
    ServerAdmin admin@foo.com
    RedirectPermanent / http://contribute.foo.com/
    CustomLog ${APACHE_LOG_DIR}/foo.com/contribute_access.log combined
    ErrorLog ${APACHE_LOG_DIR}/foo.com/contribute_error.log
</VirtualHost>

<VirtualHost *:443>
    
    # Basic configuration
    ServerName contribute.foo.com
    ServerAdmin admin@foo.com
    
    # Trac's configuration
    <Location />
        SetHandler mod_python
        PythonHandler trac.web.modpython_frontend
        PythonOption TracEnv /var/lib/trac/foo
        PythonOption TracUriRoot /
    </Location>
    <Location /login>
        AuthType Digest
        AuthName "Foo"
        AuthUserFile /var/lib/svn/foo/conf/dav_svn_passwd.digest
        BrowserMatch "MSIE" AuthDigestEnableQueryStringHack=On
        Require valid-user
    </Location>
    
    # Log configuration
    <FilesMatch \.(jpg|gif|png)$>
        SetEnvIfNoCase Referer "^https://contribute.foo.com/" local_referer=1
    </FilesMatch>
    CustomLog ${APACHE_LOG_DIR}/foo.com/contribute_access.log combined env=!local_referer
    ErrorLog ${APACHE_LOG_DIR}/foo.com/contribute_error.log
    
    # Enable SSL for this virtual host.
    SSLEngine on

    # A self-signed (snakeoil) certificate can be created by installing
    # the ssl-cert package. See
    # /usr/share/doc/apache2.2-common/README.Debian.gz for more info.
    # If both key and certificate are stored in the same file, only the
    # SSLCertificateFile directive is needed.
    SSLCertificateFile    /etc/ssl/certs/ssl-cert-snakeoil.pem
    SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key

    # Server Certificate Chain:
    # Point SSLCertificateChainFile at a file containing the
    # concatenation of PEM encoded CA certificates which form the
    # certificate chain for the server certificate. Alternatively
    # the referenced file can be the same as SSLCertificateFile
    # when the CA certificates are directly appended to the server
    # certificate for convinience.
    #SSLCertificateChainFile /etc/apache2/ssl.crt/server-ca.crt

    # Certificate Authority (CA):
    # Set the CA certificate verification path where to find CA
    # certificates for client authentication or alternatively one
    # huge file containing all of them (file must be PEM encoded)
    # Note: Inside SSLCACertificatePath you need hash symlinks
    #       to point to the certificate files. Use the provided
    #       Makefile to update the hash symlinks after changes.
    #SSLCACertificatePath /etc/ssl/certs/
    #SSLCACertificateFile /etc/apache2/ssl.crt/ca-bundle.crt

    # Settings for brain-dead browsers
    BrowserMatch "MSIE [2-6]" \
        nokeepalive ssl-unclean-shutdown \
        downgrade-1.0 force-response-1.0
    BrowserMatch "MSIE [17-9]" ssl-unclean-shutdown

</VirtualHost>

<VirtualHost *:443>
    
    # Basic configuration
    ServerName trac.foo.com
    ServerAlias wiki.foo.com
    ServerAlias admin.foo.com
    ServerAlias discussions.foo.com
    ServerAdmin admin@foo.com
    RedirectPermanent / https://contribute.foo.com/
    CustomLog ${APACHE_LOG_DIR}/foo.com/contribute_access.log combined
    ErrorLog ${APACHE_LOG_DIR}/foo.com/contribute_error.log

    # Enable SSL for this virtual host.
    SSLEngine on

    # A self-signed (snakeoil) certificate can be created by installing
    # the ssl-cert package. See
    # /usr/share/doc/apache2.2-common/README.Debian.gz for more info.
    # If both key and certificate are stored in the same file, only the
    # SSLCertificateFile directive is needed.
    SSLCertificateFile    /etc/ssl/certs/ssl-cert-snakeoil.pem
    SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key

    # Server Certificate Chain:
    # Point SSLCertificateChainFile at a file containing the
    # concatenation of PEM encoded CA certificates which form the
    # certificate chain for the server certificate. Alternatively
    # the referenced file can be the same as SSLCertificateFile
    # when the CA certificates are directly appended to the server
    # certificate for convinience.
    #SSLCertificateChainFile /etc/apache2/ssl.crt/server-ca.crt

    # Certificate Authority (CA):
    # Set the CA certificate verification path where to find CA
    # certificates for client authentication or alternatively one
    # huge file containing all of them (file must be PEM encoded)
    # Note: Inside SSLCACertificatePath you need hash symlinks
    #       to point to the certificate files. Use the provided
    #       Makefile to update the hash symlinks after changes.
    #SSLCACertificatePath /etc/ssl/certs/
    #SSLCACertificateFile /etc/apache2/ssl.crt/ca-bundle.crt

    # Settings for brain-dead browsers
    BrowserMatch "MSIE [2-6]" \
        nokeepalive ssl-unclean-shutdown \
        downgrade-1.0 force-response-1.0
    BrowserMatch "MSIE [17-9]" ssl-unclean-shutdown

</VirtualHost>

