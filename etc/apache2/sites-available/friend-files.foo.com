# /etc/apache2/sites-available/friend-files.foo.com

<VirtualHost *:80>
    ServerName friend-files.foo.com
    ServerAdmin admin@foo.com
    RedirectPermanent / https://friend-files.foo.com/
    CustomLog ${APACHE_LOG_DIR}/foo.com/friend-files_access.log combined
    ErrorLog ${APACHE_LOG_DIR}/foo.com/friend-files_error.log
</VirtualHost>

<VirtualHost *:443>
    
    # Basic configuration
    ServerName friend-files.foo.com
    ServerAdmin admin@foo.com
    DocumentRoot /data/friend-files
    
    # Options specific to the DocumentRoot directory
    <Directory /data/friend-files>
        
        # Basic options
        Options Indexes FollowSymLinks MultiViews
        
        # Customizing the listing
        IndexOptions FancyIndexing SuppressDescription SuppressHTMLPreamble
        
        # Access control
        Order Allow,Deny
        Allow from All
        
    </Directory>
    
    # WebDAV and authentication
    <Location />
        
        # Enabling DAV
        DAV On
        
        # Digest authentication for all access
        AuthType Digest
        AuthName "Friend's Things"
        AuthUserFile /home/admin/authentication/friend-files/things.digest
        BrowserMatch "MSIE" AuthDigestEnableQueryStringHack=On
        Require valid-user
        
    </Location>
    
    # Log configuration
    <FilesMatch \.(jpg|gif|png)$>
        SetEnvIfNoCase Referer "^https://friend-files.foo.com/" local_referer=1
    </FilesMatch>
    CustomLog ${APACHE_LOG_DIR}/foo.com/friend-files_access.log combined env=!local_referer
    ErrorLog ${APACHE_LOG_DIR}/foo.com/friend-files_error.log
    
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

