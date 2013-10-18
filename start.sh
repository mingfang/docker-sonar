chown -R mysql:mysql /var/lib/mysql
mysql_install_db
mysqld_safe&
sleep 3
mysql < mysql.ddl
mysqladmin shutdown
supervisord&
