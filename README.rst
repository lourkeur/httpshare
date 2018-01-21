What's this?
============

An easy-to-deploy file transfer tool.  The only requirements are:

* both devices must be connected on the same local network,

* One has a Python interpreter,

* The other has a web browser.

.. image:: https://raw.githubusercontent.com/lourkeur/httpshare/pypi/static/demo1.png
   :alt: httpshare displaying a QR code as it starts

.. image:: https://raw.githubusercontent.com/lourkeur/httpshare/pypi/static/demo2.png
   :alt: the resulting service in Firefox Mobile

Usage
=====
Make sure you have a Python interpreter set up.
It doesn't matter if it's 2.7 or 3+.
Then, simply install httpshare the normal Python way using ``pip install httpshare`` on the command line.
Then, you can call httpshare by simply typing ``httpshare`` on the command-line.
Also see ``httpshare --help``.

When launched, unless a network address was specified on the command-line, httpshare learns its address by connecting to a widely available web site. (http://github.com/)
This is reasonably likely to be the correct setting in common scenarios since most networks nowadays are primarily meant to provide access to the internet.
Once this is done, it starts listening on an ephemeral port and prints an URL to help the other device (*the guest*) connect.
The URL is supplemented by an equivalent QR code.
Once it connects, the guest can control httpshare by interacting with the web pages that it serves.
This enables file transfer in both directions.
When the guest performs a file upload, manual confirmation will be required on the host.

Limitations
===========
httpshare is not designed to protect any data against a hostile third party accessing the same local network.
It's perfectly possible that such an attacker could copy or alter the contents of the files being exchanged.
If available, use more robust file-sharing methods.
Also consider encrypting and/or authenticating data using separate tools.
Using httpshare ideally shouldn't open the host to remote code execution, but no formal guarantee is made.

httpshare is single-threaded and uses synchronous IO.
This renders it unable to serve multiple guests simultaneously.
However, it's possible to run multiple instances in parallel and assign one to each guest.

Distribution
============
Releases can be checked using PGP.
Please follow this link to `the signing key`_.

Note that a self-contained variant of this program is also available.
It's reproductibly built, and it can distribute itself through its ephemeral web site.
See here__ for more information.

__ https://github.com/lourkeur/httpshare

httpshare is `free software`_, released under the zlib/libpng License.
If you intend to distribute derivative version of this software, I would encourage using the ``PREFIX`` field in ``version.py`` to mark them as such.

.. _the signing key: https://github.com/lourkeur/httpshare/blob/pypi/release_key.asc
.. _free software: http://www.gnu.org/philosophy/free-sw.html

Trivia
======
The Python standard library module ``http.server`` (or ``SimpleHTTPServer`` in Python 2) offers similar functionality, but doesn't support uploading.
This project started with the goal of enhancing it, although it doesn't rely on code that's part of it.
