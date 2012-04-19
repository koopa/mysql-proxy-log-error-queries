mysql-proxy-log-error-queries
=============================
This is a mysql proxy lua script to log erroneous queries to a predefined table


Requirements:
-------------
mysql-proxy >= 0.8.2


Installation:
-------------
Create the following table:

    CREATE TABLE `somedb`.`mysql_error` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `date` datetime NOT NULL,
        `err_num` smallint(6) NOT NULL,
        `err_type` varchar(10) COLLATE utf8_unicode_ci NOT NULL,
        `err_message` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
        `problem_query` varchar(8000) COLLATE utf8_unicode_ci NOT NULL,
        `conn_id` int(11) NOT NULL,
        PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci

**Change `somedb`.`mysql_error` to match your log destination**

Also adjust this in the lua script.

**Edit the if condition in read_query to match your preferences.**

By default, only queries of the user "someuser" will be logged.


Usage:
------
1. > \>v0.8.2

    /path/to/mysql-proxy --proxy-lua-script=/path/to/mysql-proxy-log-error-queries.lua
2. > \>v0.9

    /path/to/mysql-proxy --proxy-lua-script=/path/to/mysql-proxy-log-error-queries.lua --plugins=proxy

By default, mysql-proxy listens on :4040.

**NB: The hostname will always be localhost!**

To connection from the shell to test, use:

    mysql -u username -p --host=127.0.0.1 --port=4040

When using a remote proxy, simply replace `127.0.0.1` with the correct remote address.




