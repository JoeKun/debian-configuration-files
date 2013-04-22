# /etc/apache2/sites-available/personal-files.foo.com

<VirtualHost *:80>
    ServerName personal-files.foo.com
    ServerAdmin admin@foo.com
    RedirectPermanent / https://personal-files.foo.com/
    CustomLog ${APACHE_LOG_DIR}/foo.com/personal-files_access.log combined
    ErrorLog ${APACHE_LOG_DIR}/foo.com/personal-files_error.log
</VirtualHost>

<VirtualHost *:443>
    
    # Basic configuration
    ServerName personal-files.foo.com
    ServerAdmin admin@foo.com
    DocumentRoot /home/foo/web/personal-files
    
    # Options specific to the DocumentRoot directory
    <Directory /home/foo/web/personal-files>
        
        # Basic options
        Options Indexes FollowSymLinks MultiViews
        
        # Customizing the listing
        IndexOptions FancyIndexing SuppressDescription SuppressHTMLPreamble
        HeaderName /.template/header.html
        ReadmeName /.template/footer.html
        IndexIgnore .template .htaccess .htdigest favicon.ico
        
        # Access control
        Order Allow,Deny
        Allow from All
        
    </Directory>
    
    # WebDAV and authentication
    <Location />
        
        # Enabling DAV
        DAV On
        
        # Digest authentication for writing files
        AuthType Digest
        AuthName "Foo"
        AuthUserFile /home/foo/web/personal-files/.htdigest
        BrowserMatch "MSIE" AuthDigestEnableQueryStringHack=On
        <LimitExcept GET>
            Require valid-user
        </LimitExcept>
        
    </Location>
    
    # Log configuration
    <FilesMatch \.(jpg|gif|png)$>
        SetEnvIfNoCase Referer "^https://personal-files.foo.com/" local_referer=1
    </FilesMatch>
    CustomLog ${APACHE_LOG_DIR}/foo.com/personal-files_access.log combined env=!local_referer
    ErrorLog ${APACHE_LOG_DIR}/foo.com/personal-files_error.log
    
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

