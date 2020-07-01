<?php

error_reporting(E_ALL ^ E_WARNING);

function waitForDb ($mariadb_host, $mariadb_user, $mariadb_user_pass, $mariadb_dbname) {

   do {
       sleep (1);
       $link = mysqli_connect($mariadb_host, $mariadb_user, $mariadb_user_pass, $mariadb_dbname);
   } while (!$link);

   exit;
}

waitForDb($argv[1], $argv[2], $argv[3], $argv[4]);

?>
