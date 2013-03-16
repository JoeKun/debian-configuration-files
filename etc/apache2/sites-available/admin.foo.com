# /etc/apache2/sites-available/admin.foo.com

<VirtualHost *:80>
    
    # Basic configuration
    ServerName admin.foo.com
    ServerAdmin admin@foo.com
    DocumentRoot /usr/local/admin
    
    # We use many Symbolic Links.
    <Directory /usr/local/admin>
        Options +FollowSymlinks
    </Directory>
    
    # CGI support
    ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
    <Directory "/usr/lib/cgi-bin">
        AllowOverride None
        Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
        Order allow,deny
        Allow from all
    </Directory>

    # phpPgAdmin
    Alias /phppgadmin /usr/share/phppgadmin
    <Directory /usr/share/phppgadmin>
        DirectoryIndex index.php
        AllowOverride None
        php_flag magic_quotes_gpc Off
        php_flag track_vars On
    </Directory>
    
    # phpMyAdmin
    Alias /phpmyadmin /usr/share/phpmyadmin
    <Directory /usr/share/phpmyadmin>
        Options FollowSymLinks
        DirectoryIndex index.php
        AddType application/x-httpd-php .php
        php_flag magic_quotes_gpc Off
        php_flag track_vars On
        php_flag register_globals Off
        php_admin_flag allow_url_fopen Off
        php_value include_path .
        php_admin_value upload_tmp_dir /var/lib/phpmyadmin/tmp
        php_admin_value open_basedir /usr/share/phpmyadmin/:/etc/phpmyadmin/:/var/lib/phpmyadmin/
    </Directory>
    <Directory /usr/share/phpmyadmin/libraries>
        Order Deny,Allow
        Deny from All
    </Directory>
    <Directory /usr/share/phpmyadmin/setup/lib>
        Order Deny,Allow
        Deny from All
    </Directory>

    # doc-central
    Alias /dc /usr/share/doc-central/www
    Alias /doc /usr/share/doc

    # Log configuration
    <FilesMatch \.(jpg|gif|png)$>
        SetEnvIfNoCase Referer "^http://admin.foo.com/" local_referer=1
    </FilesMatch>
    CustomLog ${APACHE_LOG_DIR}/foo.com/admin_access.log combined env=!local_referer
    ErrorLog ${APACHE_LOG_DIR}/foo.com/admin_error.log
    
</VirtualHost>

<VirtualHost *:443>
    
    # Basic configuration
    ServerName admin.foo.com
    ServerAdmin admin@foo.com
    DocumentRoot /usr/local/admin
    
    # We use many Symbolic Links.
    <Directory /usr/local/admin>
        Options +FollowSymlinks
    </Directory>
    
    # Log configuration
    <FilesMatch \.(jpg|gif|png)$>
        SetEnvIfNoCase Referer "^https://admin.foo.com/" local_referer=1
    </FilesMatch>
    CustomLog ${APACHE_LOG_DIR}/foo.com/admin_access.log combined env=!local_referer
    ErrorLog ${APACHE_LOG_DIR}/foo.com/admin_error.log
    
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

