# /etc/apache2/sites-available/svn.foo.com

<VirtualHost *:80>
    ServerName svn.foo.com
    ServerAdmin admin@foo.com
    RedirectPermanent / https://svn.foo.com/
    CustomLog ${APACHE_LOG_DIR}/foo.com/svn_access.log combined
    ErrorLog ${APACHE_LOG_DIR}/foo.com/svn_error.log
</VirtualHost>

<VirtualHost *:443>
    
    # Basic configuration
    ServerName svn.foo.com
    ServerAdmin admin@foo.com
    
    # Subversion repository's configuration
    <Location />
        
        # Subversion repository access
        DAV svn
        SVNPath /var/lib/svn/foo
        #AuthzSVNAccessFile /var/lib/svn/foo/conf/authz
        
        # Digest authentication for writing to repository
        AuthType Digest
        AuthName "Foo"
        AuthUserFile /var/lib/svn/foo/conf/dav_svn_passwd.digest
        BrowserMatch "MSIE" AuthDigestEnableQueryStringHack=On
        <LimitExcept GET PROPFIND OPTIONS REPORT>
            Require valid-user
        </LimitExcept>
        
    </Location>
    
    # Log configuration
    <FilesMatch \.(jpg|gif|png)$>
        SetEnvIfNoCase Referer "^https://svn.foo.com/" local_referer=1
    </FilesMatch>
    CustomLog ${APACHE_LOG_DIR}/foo.com/svn_access.log combined env=!local_referer
    ErrorLog ${APACHE_LOG_DIR}/foo.com/svn_error.log
    
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

