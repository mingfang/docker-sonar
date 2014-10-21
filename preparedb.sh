chown -R mysql:mysql /var/lib/mysql
mysql_install_db
mysqld_safe & mysqladmin --wait=5 ping
mysql < /mysql.ddl
mysqladmin shutdown
