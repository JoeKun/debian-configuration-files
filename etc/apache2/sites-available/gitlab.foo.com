# /etc/apache2/sites-available/gitlab.foo.com

<VirtualHost *:80>
    ServerName gitlab.foo.com
    ServerAdmin gitlab@foo.com
    RedirectPermanent / https://gitlab.foo.com/
    CustomLog ${APACHE_LOG_DIR}/foo.com/gitlab_access.log combined env=!local_referer
    ErrorLog ${APACHE_LOG_DIR}/foo.com/gitlab_error.log
</VirtualHost>

<VirtualHost *:443>
    
    # Basic configuration
    ServerName gitlab.foo.com
    ServerAdmin gitlab@foo.com
    
    # Proxy
    ProxyPass / http://127.0.0.1:8080/
    ProxyPassReverse / http://127.0.0.1:8080/
    ProxyPreserveHost On
    
    # Log configuration
    <FilesMatch \.(jpg|gif|png)$>
        SetEnvIfNoCase Referer "^https://gitlab.foo.com/" local_referer=1
    </FilesMatch>
    CustomLog ${APACHE_LOG_DIR}/foo.com/gitlab_access.log combined env=!local_referer
    ErrorLog ${APACHE_LOG_DIR}/foo.com/gitlab_error.log
    
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

