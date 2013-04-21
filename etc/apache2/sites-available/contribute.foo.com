# /etc/apache2/sites-available/contribute.foo.com

<VirtualHost *:80>
    ServerName contribute.foo.com
    ServerAlias trac.foo.com
    ServerAlias wiki.foo.com
    ServerAlias admin.foo.com
    ServerAlias discussions.foo.com
    ServerAdmin admin@foo.com
    RedirectPermanent / https://contribute.foo.com/
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
    
    # SSL configuration
    SSLEngine on
    SSLCertificateFile      /etc/ssl/certs/foo.com_wildcard.pem
    SSLCertificateKeyFile   /etc/ssl/private/foo.com_wildcard.key
    SSLCertificateChainFile /etc/ssl/certs/server-ca.pem
    SSLCACertificateFile    /etc/ssl/certs/ca-bundle.pem
    
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
    
    # SSL configuration
    SSLEngine on
    SSLCertificateFile      /etc/ssl/certs/foo.com_wildcard.pem
    SSLCertificateKeyFile   /etc/ssl/private/foo.com_wildcard.key
    SSLCertificateChainFile /etc/ssl/certs/server-ca.pem
    SSLCACertificateFile    /etc/ssl/certs/ca-bundle.pem
    
    # Settings for brain-dead browsers
    BrowserMatch "MSIE [2-6]" \
        nokeepalive ssl-unclean-shutdown \
        downgrade-1.0 force-response-1.0
    BrowserMatch "MSIE [17-9]" ssl-unclean-shutdown
    
</VirtualHost>

