debian-jessie-backport-systemd cookbook
=======================================

This cookbook can be used to create .deb systemd packages backported from Debian testing to Debian Jessie (8.2). If you don't know what a cookbook is, you have probably ventured too far on the Internet. See https://www.chef.io/

The cookbook is NOT MEANT to be 'cooked' on your live Debian installation. Rather, it should be 'cooked' on freshly installed Debian Jessie in a virtual machine or container.

Also, I am using backported systemd on my desktop, where I mostly develop. So you might test backported systemd packages before deploying to your servers, if you choose so.

Briefly, required steps are:
 1. Create a virtual machine or container with freshly installed Debian Jessie (8.2)
 2. Boot it up.
 3. Setup ssh in the virtual machine, so that `root` can login using the public key authentication.
 4. You need to have `knife-solo` installed on a machine, from where it can connect to your just created virtual machine.
   1. Make sure you have `ruby` installed (`aptitude install ruby ruby-dev` or similar).
   2. Install `knife-solo` by typing `gem install knife-solo berkshelf`. It is a quite hefty gem, so it might take a while.
 5. Create your own kitchen.
   1. Type `knife solo init <your_kitchen_directory>`
   2. `cd <your_kitchen_directory>`
   3. Change `Berkshelf` file to contain:
     ```
     source "https://api.berkshelf.com"

     cookbook 'backport-systemd', git: 'https://github.com/kybu/debian-jessie-backport-systemd-cookbook.git'
     ```     
 6. When using `knife-solo`, your virtual machine needs to have chef installed. `knife-solo` can do it for you by executing `knife solo prepare root@<IP_of_virtual_machine>`
 7. And now, you can start the whole backporting procedure by `knife solo cook root@<IP_of_virtual_machine> -o backport-systemd`

When the last step finishes, .deb packages are stored in `/var/lib/backport-systemd`. Type `find /var/lib/backport-systemd -name '*.deb'` to list them.

The most convenient way of installing these .deb packages to whatever Debian machine you want to have systemd backported is to create a local apt repository which will contain these packages. You can use [aptly](http://www.aptly.info/) for that. In fact, this cookbook uses it to install backported systemd in the virual machine.

How does this cookbook work?
----------------------------

This cookbook adds the Debian testing packages source repository, fetches all required source packages, patches them to avoid unnecessary package dependencies and builds the whole lot. After that, it uses [aptly](http://www.aptly.info) to create a local apt repository, where it publishes just built systemd packages and installs them using `aptitude upgrade`. Debian testing source repository is taken from [snapshots](http://snapshot.debian.org/archive/debian/20151117T093616Z) so that the same packages are being used and the backporting is reliable and immune to package changes in Debian testing.
