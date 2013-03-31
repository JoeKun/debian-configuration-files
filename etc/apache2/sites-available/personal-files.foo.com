# /etc/apache2/sites-available/personal-files.foo.com

<VirtualHost *:80>
    
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
        SetEnvIfNoCase Referer "^http://personal-files.foo.com/" local_referer=1
    </FilesMatch>
    CustomLog ${APACHE_LOG_DIR}/foo.com/personal-files_access.log combined env=!local_referer
    ErrorLog ${APACHE_LOG_DIR}/foo.com/personal-files_error.log
    
</VirtualHost>

<VirtualHost *:443>
    
    # Basic configuration
    ServerName personal-files.foo.com
    ServerAdmin admin@foo.com
    
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

