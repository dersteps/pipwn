pipwn
=====

Hi, this is pipwn!

First of all: this is a dirty hack, nothing special. And please keep in mind that this is not really exploiting anything, but simply makes use of the fact that a lot of people don't bother to change their credentials when experimenting with their raspberry pi.

When using this, please keep in mind that this is a PoC - it might have some bugs and do something unexpected to your network! And yes, I'm aware that it is not done in the best of ways. If you improve it, let me know!

License
=====
Released under the MIT license (see LICENSE file for details). 


How it works
=====
This script will simply scan a network segment for every host that listens on TCP port 22 (SSH). After that, it will attempt to access each of these hosts with the credentials you give it (I included a few credentials that people might use as their default raspberry pi logins, see credentials.lst).

On each host that the script can successfully access this way, it will then attempt to execute a command via ssh.

The cool thing is: the default user on the default RPi image is allowed to use sudo, so you might even create new users or reboot the host...the sky's the limit.

Usage
=====
This script has three modes.

**1. Default mode**
Execute the script and pass it the network segment to scan:
`./pipwn.sh 192.168.1.0/24`

**2. Credentials mode**
Pass the script a list of credentials (in a file, one set per line, see example file):
`./pipwn.sh 192.168.1.0/24 credentials.lst`

**3. Custom command mode**
Pass the script both a list of credentials and a command to execute:
`./pipwn.sh 192.168.1.0/24 credentials.lst <CMD>`

Disclaimer
=====
Don't use this for anything evil or illegal. Use on your own network and on your own risk only. I cannot be held responsible for anything you do with this script, no matter how stupid!
