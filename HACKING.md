How to work on this project
===========================

dbbackup development happens primarily on Ubuntu. Here's how our environment is
set up.

Precise
-------
TBD

Saucy
-----
As root (from a root shell prompt or using sudo):
    aptitude install rbenv ruby-build

Then, as a regular user (assuming your shell is bash):
    echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
    exec /bin/bash
    rbenv alternatives
    mkdir -p ~/ruby-defs
    echo 'install_package "ruby-2.1.0" "http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.0.tar.gz" standard' > ~/ruby-defs/2.1.0
    rbenv install ~/ruby-defs/2.1.0
