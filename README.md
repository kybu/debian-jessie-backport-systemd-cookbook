debian-jessie-backport-systemd cookbook
=======================================

This cookbook can be used to create .deb systemd packages backported from Debian testing to Debian Jessie (8.2). If you don't know what a cookbook is, you have probably ventured too far on the Internet. See https://www.chef.io/

The cookbook is NOT MEANT to be 'cooked' on your live Debian installation. Rather, it should be 'cooked' on freshly installed Debian Jessie in a virtual machine or container.

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
