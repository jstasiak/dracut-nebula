dracut-nebula
=============

``dracut-nebula`` integrates the Nebula VPN into Dracut-based `initramfs
<https://en.wikipedia.org/wiki/Initial_ramdisk>`_.

In combination with `dracut-sshd <https://github.com/gsauthof/dracut-sshd>`_ it
enables remote root filesystem unlocking (in full disk encryption scenarios)
and otherwise gives you access to the `early userspace
<https://wiki.archlinux.org/title/Arch_boot_process#Early_userspace>`_.
All via Nebula, without having to be connected to the same physical network.

Compatibility: tested on Fedora 40 but any system using Dracut as the initramfs
manager and systemd as the init system should work (with the same caveats in
``dracut-sshd`` documentation).

Copyright (c) 2024 Jakub Stasiak, MIT License

How to install dracut-nebula?
-----------------------------

#. Install ``dracut-sshd`` with the base network configuration by following the
   `dracut-sshd installation instructions
   <https://github.com/gsauthof/dracut-sshd?tab=readme-ov-file#install>`_.

   Verify that you can SSH to the Dracut emergency shell using the machine's physical IP
   address before proceeding.

#. `Install the Nebula executable
   <https://github.com/slackhq/nebula?tab=readme-ov-file#supported-platforms>`_.

#. Install ``dracut-nebula``::

        git clone https://github.com/jstasiak/dracut-nebula
        cd dracut-nebula
        cp -ri 90nebula /usr/lib/dracut/modules.d

#. Create a dedicated Nebula configuration in ``/etc/nebula-dracut-config.yml`` and set
   its owner and permissions like so::

        chown root /etc/nebula-dracut-config.yml
        chmod 600 /etc/nebula-dracut-config.yml

   **The configuration will be stored on an unencrypted filesystem and can be exfiltrated.**
   Therefore, to minimize the attack surface, it needs to be completely separate from your
   main Nebula configuration (if any). It also shouldn't be able to connect to anything
   within your Nebula network unless you have a good reason to allow that.

   Assuming you'll be using SSH to connect to the Dracut shell the configuration needs to
   allow incoming SSH connections from the appropriate hosts – port `22/tcp` unless you changed
   the port number when installing ``dracut-sshd``.

#. Regenerate initramfs::

        dracut -f -v

#. Verify the initramfs contains everything it's supposed to::

        # lsinitrd | grep / | grep nebula
        drwx------   2 root     root            0 Jul 13 02:00 etc/nebula
        -rw-------   1 root     root        14738 Jul 13 02:00 etc/nebula-dracut-config.yml
        -rw-r--r--   1 root     root         1637 Jul 13 02:00 etc/systemd/system/nebula.service
        lrwxrwxrwx   1 root     root           34 Jul 13 02:00 etc/systemd/system/sysinit.target.wants/nebula.service -> /etc/systemd/system/nebula.service
        -rwxr-xr-x   1 root     root     12422624 Jul 13 02:00 usr/bin/nebula

#. Reboot the machine and test the connection.
