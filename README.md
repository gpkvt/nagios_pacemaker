nagios_pacemaker
================

Icinga/Nagios-Script for Pacemaker/Corosync

Installation
============

Copy the Script to your Nagios-Plugin Directory. Set executable bit and allow the Nagios-User to execute the CRM-Command via sudo.

Usage
=====

Usage  : $PROGNAME [action]
    Actions:
             maintenance: Checks if maintenance property is set to true
             move       : Checks if there are manually moved resources
             failed     : Checks if there are failed actions
             inactive   : Checks if there are inactive resources
