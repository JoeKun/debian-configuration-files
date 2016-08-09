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
    AllowEncodedSlashes NoDecode
    
    # Proxy
    ProxyPreserveHost On
    <Location />
        Order deny,allow
        Allow from all
        
        # Allow forwarding to gitlab-workhorse
        ProxyPassReverse http://localhost:8181
        
        # Allow forwarding to GitLab Rails app (Unicorn)
        ProxyPassReverse http://localhost:8080
        ProxyPassReverse https://gitlab.foo.com/
    </Location>
    
    # Apache equivalent of nginx try files
    # http://serverfault.com/questions/290784/what-is-apaches-equivalent-of-nginxs-try-files
    # http://stackoverflow.com/questions/10954516/apache2-proxypass-for-rails-app-gitlab
    RewriteEngine On

    # Forward these requests to gitlab-workhorse
    RewriteCond %{REQUEST_URI} !^/(?:404\.html|422\.html|500\.html|502\.html|503\.html|deploy\.html|static\.css|logo\.svg)$
    RewriteRule .* http://localhost:8181%{REQUEST_URI} [P,QSA,NE]

    RequestHeader set X_FORWARDED_PROTO 'https'
    RequestHeader set X-Forwarded-Ssl on
    
    # Needed for downloading attachments.
    DocumentRoot /var/lib/git/gitlab/public
    
    # Set up apache error documents, if back end goes down (i.e. 503 error) then a maintenance/deploy page is thrown up.
    ErrorDocument 404 /404.html
    ErrorDocument 422 /422.html
    ErrorDocument 500 /500.html
    ErrorDocument 502 /502.html
    ErrorDocument 503 /503.html
    
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

