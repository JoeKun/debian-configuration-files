# /etc/apache2/sites-available/friend-blog.foo.com

<VirtualHost *:80>
    ServerName www.friend-blog.foo.com
    ServerAdmin friend@foo.com
    RedirectPermanent / http://friend-blog.foo.com/
    CustomLog ${APACHE_LOG_DIR}/foo.com/friend-blog_access.log combined
    ErrorLog ${APACHE_LOG_DIR}/foo.com/friend-blog_error.log
</VirtualHost>

