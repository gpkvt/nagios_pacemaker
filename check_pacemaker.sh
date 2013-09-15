#!/bin/bash

CRM="sudo /usr/sbin/crm"
GREP="/bin/grep"

PROGNAME=`/usr/bin/basename $0`
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
REVISION="0.1"

. $PROGPATH/utils.sh

print_usage() {
    echo "Usage  : $PROGNAME [action]"
    echo "Actions:"
    echo "         maintenance: Checks if maintenance property is set to true"
    echo "         move       : Checks if there are manually moved resources"
    echo "         failed     : Checks if there are failed actions"
    echo "         inactive   : Checks if there are inactive resources"
    echo ""
    echo "Usage  : $PROGNAME --help"
    echo "Usage  : $PROGNAME --version"
}

print_help() {
    print_revision $PROGNAME $REVISION
    echo ""
    print_usage
    echo ""
    echo "pacemaker/corosync status reporter for nagios"
    echo ""
    support
}

check_maintenance() {
    if $CRM configure show | $GREP 'maintenance-mode="true"' > /dev/null; then
	echo "WARNING: Maintenance Mode is active..."
	exit $STATE_WARNING
    else
	echo "OK: Maintenance Mode is inactive..."
	exit $STATE_OK
    fi
}

check_move() {
    if $CRM configure show | $GREP 'location cli-prefer' > /dev/null; then
	echo "WARNING: Manual move is active..."
	exit $STATE_WARNING
    else
	echo "OK: Manual move is inactive..."
	exit $STATE_OK
    fi
}

check_failed() {
    if $CRM status | awk '/Failed actions/ {seen = 1} seen {print}' | $GREP -v 'Failed actions:' > /dev/null; then
	echo "WARNING: Failed actions present..."
	exit $STATE_WARNING
    else
	echo "OK: No failed actions present..."
	exit $STATE_OK
    fi
}


check_inactive() {
    if ! diff -B <($CRM status | tail -n+11) <($CRM status inactive | grep -v "Full list of resources:" | tail -n+11) > /dev/null; then
	echo "CRITICAL: Inactive resources present..."
	exit $STATE_CRITICAL
    else
	echo "OK: No inactive resources present..."
	exit $STATE_OK
    fi
}

check_connection() {
    if ! $CRM configure show > /dev/null; then
	echo "CRITICAL: could not connect to CRM..."
	exit $STATE_CRITICAL
    fi
}

# Make sure the correct number of command line
# arguments have been supplied

if [ $# -lt 1 ]; then
    print_usage
    exit $STATE_UNKNOWN
fi

exitstatus=$STATE_UNKNOWN #default
while test -n "$1"; do
    case "$1" in
        --help)
            print_help
            exit $STATE_OK
            ;;
        -h)
            print_help
            exit $STATE_OK
            ;;
        --version)
            print_revision $PROGNAME $REVISION
            exit $STATE_OK
            ;;
        -V)
            print_revision $PROGNAME $REVISION
            exit $STATE_OK
            ;;
	maintenance)
	    check_connection
	    check_maintenance
	    ;;
	move)
	    check_connection
	    check_move
	    ;;
	failed)
	    check_connection
	    check_failed
	    ;;
	inactive)
	    check_connection
	    check_inactive
	    ;;
        *)
            echo "Unknown argument: $1"
            print_usage
            exit $STATE_UNKNOWN
            ;;
    esac
    shift
done

exit $exitstatus
