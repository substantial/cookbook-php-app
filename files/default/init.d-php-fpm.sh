#!/bin/sh

# Starts and stops the PHP FastCGI Process Manager daemon
# Author: Thom Mahoney
# Date: Jan 17, 2012
# Note: Adapted from another init.d script

php_fpm_BIN=/usr/bin/php-fpm
php_fpm_CONF=/etc/php-fpm.conf
php_fpm_PID=/var/run/php-fpm.pid

php_opts="--fpm-config $php_fpm_CONF"

wait_for_pid () {
	try=0

	while test $try -lt 35 ; do
		case "$1" in
			'created')
			if [ -f "$2" ] ; then
				try=''
				break
			fi
			;;

			'removed')
			if [ ! -f "$2" ] ; then
				try=''
				break
			fi
			;;
		esac

		echo -n .
		try=`expr $try + 1`
		sleep 1
	done
}

case "$1" in

	start)
		echo -n "Starting php-fpm "

		$php_fpm_BIN $php_opts

		if [ "$?" != 0 ] ; then
			echo " failed"
			exit 1
		fi

		wait_for_pid created $php_fpm_PID

		if [ -n "$try" ] ; then
			echo " failed"
			exit 1
		else
			echo " done"
		fi
	;;

	stop)
		echo -n "Gracefully shutting down php-fpm "

		if [ ! -r $php_fpm_PID ] ; then
			echo "warning, no pid file found - php-fpm is not running?"
			exit 1
		fi

		kill -QUIT `cat $php_fpm_PID`

		wait_for_pid removed $php_fpm_PID

		if [ -n "$try" ] ; then
			echo " failed. Use force-exit"
			exit 1
		else
			echo " done"
		fi
	;;

	force-quit)
		echo -n "Terminating php-fpm "

		if [ ! -r $php_fpm_PID ] ; then
			echo "warning, no pid file found - php-fpm is not running?"
			exit 1
		fi

		kill -TERM `cat $php_fpm_PID`

		wait_for_pid removed $php_fpm_PID

		if [ -n "$try" ] ; then
			echo " failed"
			exit 1
		else
			echo " done"
		fi
	;;

	restart)
		$0 stop
		$0 start
	;;

	deploy)
		$0 reload
	;;

	reload)
		echo -n "Reload service php-fpm "

		if [ ! -r $php_fpm_PID ] ; then
			echo "warning, no pid file found - php-fpm is not running?"
			exit 1
		fi

		kill -USR2 `cat $php_fpm_PID`

		echo " done"
	;;

	*)
		echo "Usage: $0 {start|stop|force-quit|restart|reload}"
		exit 1
	;;

esac
