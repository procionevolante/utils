The scripts in this repo are all free to use, modify and distribute freely
under the terms of the Do What The Fuck You Want To Public License, Version 2,
as published by Sam Hocevar. See the COPYING file for more details.

Some of them use `nawk` instead of `gawk` (which is what it's usually installed
as default AWK interpreter) to be lighter.  
For shell scripts: I tried to use `bash` only when it's actually needed
and preferred the potentially lighter and faster Bourne shell `sh` (which
is actually lighter and faster if you use for example [dash](http://gondor.apana.org.au/~herbert/dash/)
instead of [bash](https://www.gnu.org/software/bash/bash.html) as `/bin/sh`when
you only need classic shell commands)
