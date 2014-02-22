# /etc/apache2/sites-available/ci.foo.com

<VirtualHost *:80>
    ServerName ci.foo.com
    ServerAdmin ci@foo.com
    RedirectPermanent / https://ci.foo.com/
    CustomLog ${APACHE_LOG_DIR}/foo.com/ci_access.log combined env=!local_referer
    ErrorLog ${APACHE_LOG_DIR}/foo.com/ci_error.log
</VirtualHost>

<VirtualHost *:443>
    
    # Basic configuration
    ServerName ci.foo.com
    ServerAdmin ci@foo.com
    
    # Proxy
    ProxyPass / http://127.0.0.1:9292/
    ProxyPassReverse / http://127.0.0.1:9292/
    ProxyPreserveHost On
    
    # Support for secured cookies
    RequestHeader set X_FORWARDED_PROTO 'https'
    
    # Log configuration
    <FilesMatch \.(jpg|gif|png)$>
        SetEnvIfNoCase Referer "^https://ci.foo.com/" local_referer=1
    </FilesMatch>
    CustomLog ${APACHE_LOG_DIR}/foo.com/ci_access.log combined env=!local_referer
    ErrorLog ${APACHE_LOG_DIR}/foo.com/ci_error.log
    
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

