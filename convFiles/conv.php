<?php
    ini_set('display_errors', 1);
	ini_set('display_startup_errors', 1);
	error_reporting(E_ALL);

	$command = shell_exec('python conv.py '.escapeshellarg($_POST["body"]).' '.escapeshellarg($_POST["domain"]));
	echo $command;
?>
