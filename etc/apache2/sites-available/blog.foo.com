# /etc/apache2/sites-available/blog.foo.com

<VirtualHost *:80>
    
    # Basic configuration
    ServerName blog.foo.com
    ServerAdmin admin@foo.com
    DocumentRoot /home/foo/web/blog
    
    # Log configuration
    <FilesMatch \.(jpg|gif|png)$>
        SetEnvIfNoCase Referer "^http://blog.foo.com/" local_referer=1
    </FilesMatch>
    CustomLog ${APACHE_LOG_DIR}/foo.com/blog_access.log combined env=!local_referer
    ErrorLog ${APACHE_LOG_DIR}/foo.com/blog_error.log
    
</VirtualHost>

<VirtualHost *:443>
    
    # Basic configuration
    ServerName blog.foo.com
    ServerAdmin admin@foo.com
    DocumentRoot /home/foo/web/blog
    
    # Log configuration
    <FilesMatch \.(jpg|gif|png)$>
        SetEnvIfNoCase Referer "^https://blog.foo.com/" local_referer=1
    </FilesMatch>
    CustomLog ${APACHE_LOG_DIR}/foo.com/blog_access.log combined env=!local_referer
    ErrorLog ${APACHE_LOG_DIR}/foo.com/blog_error.log
    
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

