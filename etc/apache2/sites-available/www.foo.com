# /etc/apache2/sites-available/www.foo.com

<VirtualHost *:80>
    
    # Basic configuration
    ServerName www.foo.com
    ServerAdmin admin@foo.com
    DocumentRoot /home/foo/web/www
    
    # Log configuration
    <FilesMatch \.(jpg|gif|png)$>
        SetEnvIfNoCase Referer "^http://www.foo.com/" local_referer=1
    </FilesMatch>
    CustomLog ${APACHE_LOG_DIR}/foo.com/www_access.log combined env=!local_referer
    ErrorLog ${APACHE_LOG_DIR}/foo.com/www_error.log
    
</VirtualHost>

<VirtualHost *:80>
    ServerName foo.com
    ServerAdmin admin@foo.com
    RedirectPermanent / http://www.foo.com/
    CustomLog ${APACHE_LOG_DIR}/foo.com/www_access.log combined
    ErrorLog ${APACHE_LOG_DIR}/foo.com/www_error.log
</VirtualHost>

<VirtualHost *:443>
    
    # Basic configuration
    ServerName www.foo.com
    ServerAdmin admin@foo.com
    DocumentRoot /home/foo/web/www
    
    # Log configuration
    <FilesMatch \.(jpg|gif|png)$>
        SetEnvIfNoCase Referer "^https://www.foo.com/" local_referer=1
    </FilesMatch>
    CustomLog ${APACHE_LOG_DIR}/foo.com/www_access.log combined env=!local_referer
    ErrorLog ${APACHE_LOG_DIR}/foo.com/www_error.log
    
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
    ServerName foo.com
    ServerAdmin admin@foo.com
    RedirectPermanent / https://www.foo.com/
    CustomLog ${APACHE_LOG_DIR}/foo.com/www_access.log combined
    ErrorLog ${APACHE_LOG_DIR}/foo.com/www_error.log

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

